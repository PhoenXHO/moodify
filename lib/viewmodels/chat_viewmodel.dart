import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../models/chat_message.dart';
import '../models/song.dart'; // Import Song model
import '../repositories/song_repository.dart'; // Import SongRepository
import '../services/ai_service.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../viewmodels/playlists_viewmodel.dart'; // Import PlaylistsViewModel

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final AiService _aiService = AiService();
  final AuthService _authService = AuthService();
  final SongRepository _songRepository = SongRepository();
  final PlaylistsViewModel _playlistsViewModel = PlaylistsViewModel();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  StreamSubscription? _messageSubscription;
  String? _userId;
  String? _originalUserRequest; // Store original request during multi-step AI calls
  bool _isInitialized = false;
  String? searchQuery; // For search navigation

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  int get messageCount => _messages.length;

  ChatViewModel() {
    try {
      _userId = _authService
          .getCurrentUser()
          .id;

      _messageSubscription = _chatService.messageStream.listen((messages) {
        _messages = messages;
        notifyListeners();
      });
    } catch (e) {
      print('Error initializing ChatViewModel: $e');
    }
  }

  Future<void> initChat() async {
    if (_userId == null) return;
    if (_isInitialized) return; // Prevent re-initialization

    _setLoading(true);
    try {
      await _chatService.initChat(_userId!);

      // Only after initialization completes, check if we need a greeting
      // Give the listener time to receive the messages from the service
      await Future.delayed(Duration(milliseconds: 100));

      // If chat is empty after loading history, get initial greeting
      if (_messages.isEmpty) {
        await _getInitialGreeting();
      }
    } catch (e) {
      print('Error initializing chat: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _getInitialGreeting() async {
    if (_userId == null) return;
    _setLoading(true);
    try {
      // Use the 'greet' command and get raw response
      final history = _getFormattedChatHistory();
      final greeting = await _aiService.getAiResponse('greet', history);
      await _chatService.addMessage(_userId!, greeting, isUserMessage: false);
    } catch (e) {
      print('Error getting initial greeting: $e');
      // Add a fallback error message if AI fails
      await _chatService.addMessage(
        _userId!,
        'Hello! I seem to be having trouble starting up. Please try again later.',
        isUserMessage: false,
      );
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> sendMessage(String text) async {
    if (_userId == null || text.trim().isEmpty) return;

    final userMessage = text.trim();
    // Add user message immediately
    await _chatService.addMessage(_userId!, userMessage, isUserMessage: true);
    
    //_setLoading(true);

    try {
      // Prepare chat history context
      final history = _getFormattedChatHistory();
      String prompt = userMessage;
      bool isMusicRequest = _isMusicRelatedRequest(userMessage);

      // If this looks like a music/playlist request, provide moods and genres context
      if (isMusicRequest) {
        // Fetch all unique moods and genres
        final List<String> moods = await _songRepository.getAllUniqueMoods();
        final List<String> genres = await _songRepository.getAllUniqueGenres();
        
        // Format the request with moods and genres
        prompt = _formatMoodsAndGenresPrompt(moods, genres, userMessage);
        
        // Add explicit instruction for function call requirement
        prompt = "IMPORTANT: You MUST respond with ONLY this exact JSON format: {\"function\": \"FILTER_SONGS\", \"parameters\": {\"irrelevant_moods\": [...], \"irrelevant_genres\": [...]}}, with no other text. DO NOT use function_name or args in your response. " + prompt;
      }
	  
	  // Get AI response with the appropriate prompt
      final aiResponseString = await _aiService.getAiResponse(prompt, history);
      print("AI response: $aiResponseString");

      // Try to parse for a function call
      final functionCall = AiService.tryParseFunctionCall(aiResponseString);

      // Handle the response based on whether it's a music request and a function call
      if (functionCall != null) {
        // Store the original request if starting a function sequence
        _originalUserRequest = userMessage;
        await _handleFunctionCall(functionCall);
      } else {
        // If not a function call or music request, just add the response as a message
        await _chatService.addMessage(_userId!, aiResponseString, isUserMessage: false);
        _originalUserRequest = null; // Clear original request if it was a normal message
      }
	} catch (e) {
      print('Error sending message or getting AI response: $e');
      await _chatService.addMessage(
        _userId!,
        'Sorry, I encountered an error processing your request. Please try again.',
        isUserMessage: false,
      );
      _originalUserRequest = null; // Clear original request on error
    } finally {
      _setLoading(false);
    }
  }

  // --- Function Call Handling ---

  Future<void> _handleFunctionCall(Map<String, dynamic> functionCall) async {
    final functionName = functionCall['function'];
    final parameters = functionCall['parameters'] as Map<String, dynamic>;

    switch (functionName) {
      case 'FILTER_SONGS':
        await _handleFilterSongs(parameters);
        break;
      case 'SELECT_SONGS':
        // Handle song selection and playlist creation
        final songIds = List<String>.from(parameters['song_ids'] ?? []);
        if (songIds.isNotEmpty && _originalUserRequest != null) {
          await _createPlaylistFromSelectedSongs(songIds, _originalUserRequest!);
        } else {
          await _chatService.addMessage(
            _userId!,
            "I couldn't create a playlist because no songs were selected or the request was lost.",
            isUserMessage: false,
          );
        }
        _originalUserRequest = null; // Clear original request after completion
        break;
      case 'SEARCH_SONG':
        // Implement song search logic
        final searchQuery = parameters['query'] as String? ?? '';
        await _handleSongSearch(searchQuery);
        _originalUserRequest = null; // Clear original request
        break;
      default:
        print('Unknown function call: $functionName');
        await _chatService.addMessage(
          _userId!,
          "Sorry, I received an instruction I don't understand.",
          isUserMessage: false,
        );
        _originalUserRequest = null; // Clear original request
    }
  }

  Future<void> _handleFilterSongs(Map<String, dynamic> parameters) async {
     if (_userId == null || _originalUserRequest == null) {
       print("Error: Missing user ID or original request for FILTER_SONGS");
       await _chatService.addMessage(_userId!, "Something went wrong, I lost the context of your request.", isUserMessage: false);
       return;
     }

    // 1. Get irrelevant moods/genres from the first AI response
    final irrelevantMoods = List<String>.from(parameters['irrelevant_moods'] ?? []);
    final irrelevantGenres = List<String>.from(parameters['irrelevant_genres'] ?? []);

    // Optional: Inform user about filtering (can be removed later)
    // await _chatService.addMessage(
    //   _userId!,
    //   "Okay, I'll filter out songs with moods like [${irrelevantMoods.join(', ')}] and genres like [${irrelevantGenres.join(', ')}]. Now selecting the best matches...",
    //   isUserMessage: false,
    // );
    // _setLoading(true); // Keep loading indicator

    try {
      // 2. Fetch filtered songs from the repository
      final filteredSongs = await _songRepository.getFilteredSongs(
        excludeMoods: irrelevantMoods,
        excludeGenres: irrelevantGenres,
        limit: 100, // Fetch top 100 relevant songs
      );

      if (filteredSongs.isEmpty) {
        await _chatService.addMessage(
          _userId!,
          "I couldn't find any songs matching your criteria after filtering. Try adjusting your request?",
          isUserMessage: false,
        );
         _originalUserRequest = null; // Clear original request
        return;
      }

      // 3. Prepare the prompt for the second AI call (SELECT_SONGS)
      final prompt = _formatSelectSongsPrompt(filteredSongs, _originalUserRequest!);
      final history = _getFormattedChatHistory(); // Get history again for context

      // 4. Call AI again to select songs from the filtered list
      final aiResponseString = await _aiService.getAiResponse(prompt, history);

      // 5. Parse the second response for SELECT_SONGS function call
      final functionCall = AiService.tryParseFunctionCall(aiResponseString);

      if (functionCall != null && functionCall['function'] == 'SELECT_SONGS') {
        // Handle the SELECT_SONGS response (which just adds a message for now)
        await _handleFunctionCall(functionCall);
      } else {
        // If the second call didn't return the expected function or failed parsing
        print("AI did not return SELECT_SONGS as expected. Response: $aiResponseString");
        await _chatService.addMessage(
          _userId!,
          "I got the filtered songs, but had trouble selecting the final list. Here's the raw response: $aiResponseString", // Or a more user-friendly error
          isUserMessage: false,
        );
         _originalUserRequest = null; // Clear original request on error
      }
    } catch (e) {
      print('Error during song filtering/selection process: $e');
      await _chatService.addMessage(
        _userId!,
        'Sorry, an error occurred while finding songs for you. Please try again.',
        isUserMessage: false,
      );
       _originalUserRequest = null; // Clear original request on error
    } finally {
       // Loading state is handled by the final call to _handleFunctionCall or error handling
    }
  }

  Future<void> _createPlaylistFromSelectedSongs(List<String> songIds, String userRequest) async {
    if (_userId == null) {
      await _chatService.addMessage(
        _userId!,
        "You need to be logged in to create playlists.",
        isUserMessage: false,
      );
      return;
    }

    try {
      // Generate a playlist title using AI based on the user request
      final history = _getFormattedChatHistory();
      final promptForTitle = "Create a short, catchy playlist title (max 5 words) based on this user request, without quotes or explanation: $userRequest";
      
      _setLoading(true);
      final titleResponse = await _aiService.getAiResponse(promptForTitle, history);
      
      // Clean the title (remove quotes and any additional text)
      final cleanTitle = _cleanPlaylistTitle(titleResponse);
      
      // Create a description based on the user request
      final description = "Created based on: $userRequest";
      
      // Create the playlist with the selected songs
      final playlistId = await _playlistsViewModel.createPlaylistWithSongs(
        title: cleanTitle,
        description: description,
        songIds: songIds,
      );
      
      if (playlistId != null) {
        await _chatService.addMessage(
          _userId!,
          "I've created a playlist with ${songIds.length} songs based on your request. You can find it in your library!",
          isUserMessage: false,
          playlistId: playlistId,
          playlistName: cleanTitle,
        );
      } else {
        await _chatService.addMessage(
          _userId!,
          "I selected songs for you but couldn't create the playlist due to an error. Please try again later.",
          isUserMessage: false,
        );
      }
    } catch (e) {
      print("Error creating playlist: $e");
      await _chatService.addMessage(
        _userId!,
        "I encountered an error while creating your playlist. Please try again later.",
        isUserMessage: false,
      );
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper to clean AI-generated playlist title
  String _cleanPlaylistTitle(String rawTitle) {
    // Remove any quotes (single or double)
    var cleaned = rawTitle.replaceAll(RegExp(r'''["']'''), '').trim();
    
    // If the AI returned additional text, take just the first line or sentence
    if (cleaned.contains('\n')) {
      cleaned = cleaned.split('\n').first.trim();
    }
    if (cleaned.contains('.')) {
      cleaned = cleaned.split('.').first.trim();
    }
    
    // Make sure it's not too long
    if (cleaned.split(' ').length > 5) {
      cleaned = cleaned.split(' ').take(5).join(' ').trim();
    }
    
    // Fallback if nothing good was generated
    if (cleaned.length < 3) {
      return "Moodify Playlist";
    }
    
    return cleaned;
  }

  // --- Prompt Formatting Helpers ---

  // This space intentionally left blank

   String _formatSelectSongsPrompt(List<Song> songs, String originalRequest) {
    final buffer = StringBuffer(
        "Please select the best songs from this list for the user's request '$originalRequest':\n");
    for (final song in songs) {
      buffer.writeln(
          "- ${song.title}: { 'id': ${song.id}, 'moods': ${song.moods}, 'genres': ${song.genres} }, favorite count: ${song.favoriteCount}");
    }
    return buffer.toString();
  }

  // Format the available moods and genres for the AI
  String _formatMoodsAndGenresPrompt(List<String> moods, List<String> genres, String userRequest) {
    final buffer = StringBuffer("Available moods and genres in the database:\n");
    
    buffer.writeln("MOODS: ${moods.join(', ')}");
    buffer.writeln("GENRES: ${genres.join(', ')}");
    
    buffer.writeln("\nUser request: $userRequest");
    return buffer.toString();
  }

  // --- Chat History Formatting ---

  String _getFormattedChatHistory() {
    // Get the last 15 messages.
    final messagesToFormat = _messages.length > 15
        ? _messages.sublist(_messages.length - 15)
        : _messages;

    if (messagesToFormat.isEmpty) {
      return 'CHAT HISTORY: None';
    }

    final historyBuffer = StringBuffer('CHAT HISTORY:\n');
    // Add current time at the beginning of the history context
    final currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    historyBuffer.writeln('Current time: $currentTime\n');

    for (final msg in messagesToFormat) {
      final sender = msg.isUserMessage ? 'User' : 'Moody';
      final timestamp = msg.timestamp != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(msg.timestamp!)
          : '[timestamp unavailable]';
      historyBuffer.writeln('[$sender] [$timestamp]: ${msg.text}');
    }
    return historyBuffer.toString();
  }

  // -- Other Helper Methods --

  Future<void> clearChatHistory() async {
    if (_userId == null) return;

    _setLoading(true);
    _isInitialized = false; // Reset initialization state

    try {
      await _chatService.clearChatHistory(_userId!);
      _originalUserRequest = null; // Clear request context

      // Give stream time to propagate the cleared state
      await Future.delayed(Duration(milliseconds: 100));

      // After clearing, get a new greeting
      await _getInitialGreeting();
    } catch (e) {
      print('Error clearing chat history: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    // Avoid unnecessary notifications if the state hasn't changed
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
  
  Future<void> _handleSongSearch(String query) async {
    if (_userId == null) {
      print("Error: Missing user ID for song search");
      await _chatService.addMessage(
        _userId ?? 'unknown',
        "Sorry, I couldn't search for songs at this time. Please make sure you're logged in.",
        isUserMessage: false,
      );
      return;
    }

    if (query.trim().isEmpty) {
      await _chatService.addMessage(
        _userId!,
        "I need a search term to find songs. Please tell me what you're looking for.",
        isUserMessage: false,
      );
      return;
    }

    _setLoading(true);
    try {
      // Preview message before opening the search screen
      await _chatService.addMessage(
        _userId!,
        "Searching for songs matching '$query'. Opening search results...",
        isUserMessage: false,
      );
      
      // Store search query for navigation
      searchQuery = query;
      // Notify listeners to trigger navigation from the ChatScreen
      notifyListeners();
    } catch (e) {
      print("Error searching for songs: $e");
      await _chatService.addMessage(
        _userId!,
        "Sorry, I encountered an error while searching for songs. Please try again later.",
        isUserMessage: false,
      );
    } finally {      _setLoading(false);
    }
  }

  // Check if a request is music-related
  bool _isMusicRelatedRequest(String text) {
    final lowerText = text.toLowerCase();
    
    final List<String> musicKeywords = [
      'playlist', 'music', 'song', 'songs', 'track', 'tracks', 
      'listen', 'mood', 'genre', 'artist', 'album', 'vibe',
      'create', 'make', 'generate', 'recommend', 'suggest',
      'happy', 'sad', 'energetic', 'calm', 'workout', 'study',
      'relax', 'party', 'dance', 'chill', 'focus', 'concentrate'
    ];
    
    return musicKeywords.any((keyword) => lowerText.contains(keyword));
  }
}
