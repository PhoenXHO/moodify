import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/credentials.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
    static const String _credentialsKey = 'saved_credentials';


  Future<String> signUp({
    required String displayName, // Changed from username to displayName
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName, // Use displayName here
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
  }    Future<String> login({
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
    }  }
  
  // These methods are now managed by the AuthViewModel
  // We're keeping them here for backward compatibility but they should be considered deprecated
  Future<void> saveCredentials(Credentials credentials) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_credentialsKey, credentials.toJson().toString());
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_credentialsKey);
  }

  Future<Credentials?> getStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString(_credentialsKey);
    if (storedData != null) {
      try {
        return Credentials.fromJson(Map<String, dynamic>.from(
            // ignore: unnecessary_cast
            storedData as Map<String, dynamic>));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<User?> getCurrentUserProfile() async {
    return _supabase.auth.currentUser;
  }

  Future<String> updateDisplayName(String newName) async {
    final response = await _supabase.auth.updateUser(
      UserAttributes(data: {'display_name': newName}),
    );
    return response.user != null ? "success" : "error";
  }

  Future<String> updateEmail(String email) async {
    final response = await _supabase.auth.updateUser(
      UserAttributes(email: email),
    );
    return response.user != null ? "success" : "error";
  }

  Future<String> updatePassword(String password) async {
    final response = await _supabase.auth.updateUser(
      UserAttributes(password: password),
    );
    return response.user != null ? "success" : "error";
  }
}