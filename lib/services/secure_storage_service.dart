import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:emotion_music_player/models/credentials.dart';

class SecureStorageService {
  static const _emailKey = 'secure_email';
  static const _passwordKey = 'secure_password';
  static const _rememberMeKey = 'secure_remember_me';
  static const _encryptionKeyKey = 'encryption_key';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Generate a random encryption key if none exists
  Future<Key> _getEncryptionKey() async {
    String? storedKey = await _secureStorage.read(key: _encryptionKeyKey);
    
    if (storedKey == null) {
      // Generate a new key
      final key = Key.fromSecureRandom(32);
      final keyString = base64Encode(key.bytes);
      await _secureStorage.write(key: _encryptionKeyKey, value: keyString);
      return key;
    } else {
      // Use existing key
      return Key(base64Decode(storedKey));
    }
  }
  
  // Encrypt sensitive data
  Future<String> _encrypt(String data) async {
    final key = await _getEncryptionKey();
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key));
    
    final encrypted = encrypter.encrypt(data, iv: iv);
    
    // Store both the IV and encrypted data
    return "${base64Encode(iv.bytes)}:${encrypted.base64}";
  }
  
  // Decrypt sensitive data
  Future<String?> _decrypt(String? encryptedData) async {
    if (encryptedData == null) return null;
    
    try {
      final parts = encryptedData.split(':');
      if (parts.length != 2) return null;
      
      final iv = IV(base64Decode(parts[0]));
      final encrypted = Encrypted.fromBase64(parts[1]);
      
      final key = await _getEncryptionKey();
      final encrypter = Encrypter(AES(key));
      
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      print("Decryption error: $e");
      return null;
    }
  }
  
  // Store credentials securely
  Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.write(key: _emailKey, value: email);
    final encryptedPassword = await _encrypt(password);
    await _secureStorage.write(key: _passwordKey, value: encryptedPassword);
    await _secureStorage.write(key: _rememberMeKey, value: 'true');
  }
  
  // Clear saved credentials
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _passwordKey);
    await _secureStorage.delete(key: _rememberMeKey);
  }
  
  // Check if credentials are saved
  Future<bool> hasCredentials() async {
    final rememberMe = await _secureStorage.read(key: _rememberMeKey);
    return rememberMe == 'true';
  }
  
  // Get the saved credentials
  Future<Credentials?> getCredentials() async {
    final rememberMe = await _secureStorage.read(key: _rememberMeKey);
    
    if (rememberMe == 'true') {
      final email = await _secureStorage.read(key: _emailKey);
      final encryptedPassword = await _secureStorage.read(key: _passwordKey);
      final password = await _decrypt(encryptedPassword);
      
      if (email != null && password != null) {
        return Credentials(email: email, password: password);
      }
    }
    
    return null;
  }
}
