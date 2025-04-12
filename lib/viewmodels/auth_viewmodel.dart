import 'package:flutter/material.dart';
import 'package:emotion_music_player/repositories/auth_repository.dart';

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
    fetchUserProfile();
  }

  void checkAuthStatus() {
    final user = _authRepository.getCurrentUser();
    _isAuthenticated = user != null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result =
          await _authRepository.login(email: email, password: password);
      if (result.user != null) {
        _isAuthenticated = true;
        fetchUserProfile();
        return true;
      } else {
        _errorMessage = result.session?.accessToken ?? "Login failed";
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
        fetchUserProfile();
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
