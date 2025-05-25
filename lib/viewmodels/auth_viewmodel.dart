import 'package:emotion_music_player/repositories/auth_repository.dart';
import 'package:emotion_music_player/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/credentials.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final SecureStorageService _secureStorage = SecureStorageService();
  final SupabaseClient _supabase = Supabase.instance.client;

  GoogleSignIn? _googleSignIn;

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
    _initializeGoogleSignIn();
    checkAuthStatus();
  }

  void _initializeGoogleSignIn() {
    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];

    if (webClientId != null && webClientId.isNotEmpty) {
      _googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
        scopes: ['email'],
      );
    } else {
      print("Google Web Client ID is not configured in .env file. Google Sign-In will not be available.");
    }
  }

  void checkAuthStatus() {
    final user = _authRepository.getCurrentUser();
    _isAuthenticated = user != null;
    if (_isAuthenticated && user != null) {
      _displayName = user.userMetadata?['display_name'] ??
                     user.userMetadata?['name'] ?? // For Google Sign-In
                     user.email;
      _email = user.email;
    } else {
      _displayName = null;
      _email = null;
    }
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    final user = await _authRepository.getCurrentUserProfile();
    if (user != null) {
      _displayName = user.userMetadata?['display_name'] ??
                     user.userMetadata?['name'] ?? // For Google Sign-In
                     user.email;
      _email = user.email;
      _isAuthenticated = true;
    } else {
      _displayName = null;
      _email = null;
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password, bool rememberMe) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(email: email, password: password);
      
      // Handle remember me preference
      if (rememberMe) {
        await saveCredentials(email, password);
      } else {
        await clearCredentials();
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

  Future<bool> signUp(String displayName, String email, String password) async { // Changed username to displayName
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.signUp(
          displayName: displayName, email: email, password: password); // Changed username to displayName
      if (result == "success") {
        _isAuthenticated = true;
        // Fetch the display name after successful sign up
        await fetchUserProfile(); 
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

  Future<bool> signInWithGoogle() async {
    if (_googleSignIn == null) {
      _errorMessage = "Google Sign-In is not configured";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.idToken == null) {
        _errorMessage = "Failed to get Google ID token";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Sign in to Supabase using the Google ID token
      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user != null) {
        _isAuthenticated = true;
        _displayName = response.user!.userMetadata?['name'] ?? 
                       response.user!.userMetadata?['display_name'] ?? 
                       response.user!.email;
        _email = response.user!.email;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Failed to authenticate with Supabase";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Google Sign-In failed: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    // Sign out from Google if user signed in with Google
    if (_googleSignIn != null) {
      await _googleSignIn!.signOut();
    }
    
    await _authRepository.signOut();
    _isAuthenticated = false;
    _displayName = null;
    _email = null;
    _isLoading = false; // Reset isLoading state
    notifyListeners();
  }

  Future<void> saveCredentials(String email, String password) async {
    // Use secure storage for sensitive credentials
    await _secureStorage.saveCredentials(email, password);
  }
  
  Future<void> clearCredentials() async {
    await _secureStorage.clearCredentials();
  }
  
  Future<Credentials?> getRememberedCredentials() async {
    return await _secureStorage.getCredentials();
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
