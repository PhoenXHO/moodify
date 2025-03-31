import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': username,
          'username': username,
        },
      );

      if (response.user != null) {
        return "success";
      } else {
        return "An error occurred. Please try again.";
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return "success";
      } else {
        return "An error occurred. Please try again.";
      }
    } catch (e) {
      return e.toString();
    }
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}