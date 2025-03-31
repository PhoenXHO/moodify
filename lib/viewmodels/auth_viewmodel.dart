import 'package:emotion_music_player/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  AuthViewModel() {
    checkAuthStatus();
  }

  void checkAuthStatus() async {
    final user = _authRepository.getCurrentUser();
    _isAuthenticated = user != null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(email: email, password: password);
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
      final result = await _authRepository.signUp(username: username, email: email, password: password);
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
}