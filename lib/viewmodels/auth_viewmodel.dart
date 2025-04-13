import 'package:emotion_music_player/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/credentials.dart';
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  String? _displayName;
  String? _email;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  String? get displayName => _displayName;
  String? get displayEmail => _email;

  AuthViewModel() {
    checkAuthStatus();
  }

  void checkAuthStatus() {
    final user = _authRepository.getCurrentUser();
    _isAuthenticated = user != null;
    notifyListeners();
  }

  Future<bool> login(String email, String password, bool rememberMe) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(email: email, password: password);
      if (rememberMe) {
        // Save credentials
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setBool('rememberMe', true);
      }
      
      if (result == "success") {
        _isAuthenticated = true;
        return true;
      } else {
        _errorMessage = result;
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.signUp(
          username: username, email: email, password: password);
      if (result == "success") {
        _isAuthenticated = true;
        return true;
      } else {
        _errorMessage = result;
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
  }
  Future<Credentials?> getRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    if (email != null && password != null) {
      return Credentials(email: email, password: password);
    }
    return null;
  }


  Future<void> fetchUserProfile() async {
    final user = await _authRepository.getCurrentUserProfile();
    if (user != null) {
      _displayName = user.userMetadata?['display_name'] ?? '';
      _email = user.email;
      notifyListeners();
    }
  }

  Future<bool> updateDisplayName(String newName) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authRepository.updateDisplayName(newName);

    _isLoading = false;
    if (result == "success") {
      _displayName = newName;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEmail(String newemail) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authRepository.updateEmail(newemail);

    _isLoading = false;
    if (result == "success") {
      _email = newemail;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword(String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authRepository.updatePassword(password);

    _isLoading = false;
    if (result == "success") {
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result;
      notifyListeners();
      return false;
    }
  }
}
