import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUserMessage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUserMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUserMessage)
            const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.music_note, color: Colors.white, size: 14),
            ),
          if (!isUserMessage) const SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: isUserMessage
                  ? AppColors.surfaceLight
                  : AppColors.primary.withOpacity(0.9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isUserMessage ? 16 : 4),
                topRight: Radius.circular(isUserMessage ? 4 : 16),
                bottomLeft: const Radius.circular(16),
                bottomRight: const Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.2),
                ),
              ],
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isUserMessage ? AppColors.textPrimary : Colors.white,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
          if (isUserMessage) const SizedBox(width: 8),
          if (isUserMessage)
            const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.cardBackground,
              child: Icon(Icons.person, color: AppColors.textSecondary, size: 14),
            ),
        ],
      ),
    );
  }
}