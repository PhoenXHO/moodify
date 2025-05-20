
import 'package:emotion_music_player/views/emotion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/chat_viewmodel.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Assistant'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // Add option to clear chat history
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearHistoryDialog(),
            tooltip: 'Clear chat history',
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EmotionView()),
              );
            },
            tooltip: 'Open camera',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.messages.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                // Update the previous message count for the listener check
                _previousMessageCount = viewModel.messageCount;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: viewModel.messageCount,
                  itemBuilder: (context, index) {
                    final message = viewModel.messages[index];
                    return MessageBubble(
                      message: message.text,
                      isUserMessage: message.isUserMessage,
                    );
                  },
                );
              },
            ),
          ),

          // Input area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 6,
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _handleSendPressed(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  FloatingActionButton(
                    onPressed: _handleSendPressed,
                    backgroundColor: Colors.deepPurple,
                    elevation: 0,
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
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
        title: const Text('Clear chat history'),
        content: const Text(
            'Are you sure you want to clear your chat history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
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
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }
}
