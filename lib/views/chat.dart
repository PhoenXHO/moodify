import 'package:emotion_music_player/views/emotion.dart';
import 'package:emotion_music_player/views/search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../theme/dimensions.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../viewmodels/player_viewmodel.dart';
import '../widgets/message_bubble.dart';
import '../widgets/playlist_message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String? initialPrompt;
  
  const ChatScreen({super.key, this.initialPrompt});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatViewModel _chatViewModel;
  int _previousMessageCount = 0;
  @override
  void initState() {
    super.initState();
    // Get the view model
    _chatViewModel = Provider.of<ChatViewModel>(context, listen: false);

    // Initialize chat history
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _chatViewModel.initChat();
      
      // If an initial prompt was provided, send it automatically
      if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
        // Short delay to allow chat to initialize
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          _messageController.text = widget.initialPrompt!;
          _handleSendPressed();
        }
      }
    });

    // Listen for changes to the message list
    _chatViewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    // Only scroll to bottom if new messages are added
    if (_chatViewModel.messageCount > _previousMessageCount) {
      _previousMessageCount = _chatViewModel.messageCount;
      _scrollToBottom();
    }
    
    // Check if there's a search query to navigate to search screen
    if (_chatViewModel.searchQuery != null) {
      _navigateToSearchScreen(_chatViewModel.searchQuery!);
      _chatViewModel.searchQuery = null; // Reset after navigating
    }
  }
  
  void _navigateToSearchScreen(String query) {
    // Slight delay to allow the chat message to be displayed first
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen(initialQuery: query),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatViewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _handleSendPressed() {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    // Send message through view model
    _chatViewModel.sendMessage(messageText);
    _messageController.clear();
  }

  void _scrollToBottom() {
    // Scroll to bottom of chat after adding a new message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    // Check if mini-player is visible to add padding
    final playerViewModel = Provider.of<PlayerViewModel>(context);
    final isMiniPlayerVisible = playerViewModel.currentSong != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.camera_alt_outlined, size: Dimensions.iconSize),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EmotionView()),
            );
          },
          tooltip: 'Open camera',
        ),
        title: const Text(
          'Music Assistant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.background,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, size: Dimensions.iconSize),
            onPressed: () {
              _showClearHistoryDialog();
            },
            tooltip: 'Clear chat history',
          ),
          IconButton(
            icon: const Icon(Icons.search, size: Dimensions.iconSize),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(initialQuery: ''),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.messages.isEmpty) { // Show loader only on initial load when messages are empty
                  return const Center(child: CircularProgressIndicator());
                }
                if (viewModel.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.music_note_rounded,
                            color: AppColors.primary.withOpacity(0.8),
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Start a conversation to discover music based on your mood or preferences',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            _messageController.text = "Recommend me some happy songs";
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceLight,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(color: AppColors.divider),
                            ),
                          ),
                          child: const Text("Try \"Recommend me some happy songs\""),
                        ),
                      ],
                    ),
                  );
                }

                // Update the previous message count for the listener check
                _previousMessageCount = viewModel.messageCount;

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: isMiniPlayerVisible ? Dimensions.miniPlayerMinimizedHeight + 16.0 : 16.0,
                  ),
                  itemCount: viewModel.messageCount + 1, // Add 1 for the welcome message
                  itemBuilder: (context, index) {
                    // Show a welcome message at the top
                    if (index == 0) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(color: AppColors.divider, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.music_note_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Welcome to Music Assistant',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ask me to find songs, create playlists, or recommend music based on your mood!',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }                    final messageIndex = index - 1; // Adjust for welcome message
                    final message = viewModel.messages[messageIndex];
                    
                    // Check if this is a playlist message
                    if (message.isPlaylistMessage && message.playlistName != null) {
                      return PlaylistMessageBubble(
                        message: message.text,
                        playlistName: message.playlistName!,
                        playlistId: message.playlistId,
                      );
                    } else {
                      // Regular message
                      return MessageBubble(
                        message: message.text,
                        isUserMessage: message.isUserMessage,
                      );
                    }
                  },
                );
              },
            ),
          ),
          // Input field and send button
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 6,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 12.0,
                bottom: 16.0,
              ),
              child: Row(
                children: [
                  // Text field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.divider,
                          width: 1.0,
                        ),
                      ),
                      child: ClipRRect(  // Added ClipRRect to ensure content is clipped to the container's border radius
                        borderRadius: BorderRadius.circular(24),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16.0,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.7),
                              fontSize: 16.0,
                            ),
                            // Keep border radius consistent but add focus outline
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.primary, width: 2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            // Maintain consistent padding
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceLight,  // Match container color
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.mic_none_rounded,
                                color: AppColors.textSecondary.withOpacity(0.7),
                                size: 20,
                              ),
                              onPressed: () {
                                // Voice input functionality could be added here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Voice input coming soon!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _handleSendPressed(),
                          cursorColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Send button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _handleSendPressed,
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      tooltip: 'Send message',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Clear chat history', 
          style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to clear your chat history? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CANCEL', 
              style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _chatViewModel.clearChatHistory();

              // Scroll to top after clearing
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(0);
              }
            },
            child: Text('CLEAR', 
              style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
