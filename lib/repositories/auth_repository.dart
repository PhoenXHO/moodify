import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  Future<AuthResponse> login({required String email, required String password}) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<String> signUp({required String username, required String email, required String password}) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': username},
    );
    return response.user != null ? "success" : "error";
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<User?> getCurrentUserProfile() async {
    return _client.auth.currentUser;
  }

  Future<String> updateDisplayName(String newName) async {
    final response = await _client.auth.updateUser(
      UserAttributes(data: {'display_name': newName}),
    );
    return response.user != null ? "success" : "error";
  }

  Future<String> updateEmail(String email) async {
    final response = await _client.auth.updateUser(
      UserAttributes(email: email),
    );
    return response.user != null ? "success" : "error";
  }

  Future<String> updatePassword(String password) async {
    final response = await _client.auth.updateUser(
      UserAttributes(password: password),
    );
    return response.user != null ? "success" : "error";
  }
}
