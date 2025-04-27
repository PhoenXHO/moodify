import 'package:emotion_music_player/views/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/auth_repository.dart';

class AuthService {
  // This class is responsible for handling authentication-related operations

  final SupabaseClient _supabase = Supabase.instance.client;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Get current user
  User getCurrentUser() {
    // Ensure the user is logged in
    final user = _supabase.auth.currentUser;
    if (user == null) {
      // Redirect to login
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      );
    }
    return user!;
  }
}