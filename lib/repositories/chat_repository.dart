import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_message.dart';

class ChatRepository {
  // This class is responsible for handling chat data persistence

  final _supabase = Supabase.instance.client;

  // Fetch chat history for a user
  Future<List<ChatMessage>> getChatHistory(String userId) async {
    try {
      final response = await _supabase
          .from('chat_messages')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true); // Order by timestamp

      if (response.isEmpty) {
        return [];
      }

      return response.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching chat history: $e');
      throw Exception('Failed to fetch chat history');
    }
  }

  // Save a chat message
  Future<void> saveMessage(ChatMessage message) async {
    try {
      await _supabase.from('chat_messages').insert(message.toJson());
    } catch (e) {
      print('Error saving message: $e');
      throw Exception('Failed to save message');
    }
  }

  // Clear chat history for a user
  Future<void> clearChatHistory(String userId) async {
    try {
      await _supabase.from('chat_messages').delete().eq('user_id', userId);
    } catch (e) {
      print('Error clearing chat history: $e');
      throw Exception('Failed to clear chat history');
    }
  }
}
