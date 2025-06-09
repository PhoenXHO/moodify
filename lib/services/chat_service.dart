import 'dart:async';

import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';

class ChatService {
  // This class is responsible for managing chat-related operations

  // Singleton pattern
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;

  final ChatRepository _chatRepository = ChatRepository();
  final List<ChatMessage> _messages = [];

  final _messageStreamController = StreamController<List<ChatMessage>>.broadcast();
  Stream<List<ChatMessage>> get messageStream => _messageStreamController.stream;

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  // Private constructor to prevent instantiation
  ChatService._internal();

  // Initialize chat by loading history from database
  Future<void> initChat(String userId) async {
    try {
      final chatHistory = await _chatRepository.getChatHistory(userId);

      _messages.clear();
      _notifyListeners();

      if (chatHistory.isNotEmpty) {
        _messages.addAll(chatHistory);
        _notifyListeners();
      }
    } catch (e) {
      print('Error loading chat history: $e');
      // Clear messages in case of error before adding history
      _messages.clear(); 
      _notifyListeners();
    }
  }

  // Send a message
  Future<void> addMessage(String userId, String text, {
    bool isUserMessage = true, 
    String? playlistId,
    String? playlistName,
  }) async {
    final message = ChatMessage(
      userId: userId,
      text: text,
      isUserMessage: isUserMessage,
      timestamp: DateTime.now(),
      playlistId: playlistId,
      playlistName: playlistName,
      isPlaylistMessage: playlistId != null && playlistName != null,
    );

    _messages.add(message);
    await _chatRepository.saveMessage(message); 
    _notifyListeners();
  }
  
  // Helper method for adding playlist messages
  Future<void> addPlaylistMessage(String userId, String text, String playlistId, String playlistName) async {
    await addMessage(
      userId, 
      text, 
      isUserMessage: false,
      playlistId: playlistId,
      playlistName: playlistName,
    );
  }

  // Clear chat history
  Future<void> clearChatHistory(String userId) async {
    await _chatRepository.clearChatHistory(userId);
    _messages.clear();
    _notifyListeners();
  }

  // Notify listeners about changes
  void _notifyListeners() {
    _messageStreamController.add(List.unmodifiable(_messages)); // Ensure immutability
  }

  // Dispose the stream controller when the service is no longer needed
  void dispose() {
    _messageStreamController.close();
  }
}