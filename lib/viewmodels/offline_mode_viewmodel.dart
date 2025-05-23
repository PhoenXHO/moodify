import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineModeViewModel extends ChangeNotifier {
  static const String _offlineModeKey = 'offline_mode_enabled';
  bool _isOfflineModeEnabled = false;

  bool get isOfflineModeEnabled => _isOfflineModeEnabled;

  OfflineModeViewModel() {
    _loadOfflineModePreference();
  }

  Future<void> _loadOfflineModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isOfflineModeEnabled = prefs.getBool(_offlineModeKey) ?? false;
    notifyListeners();
  }

  Future<void> setOfflineMode(bool isEnabled) async {
    _isOfflineModeEnabled = isEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineModeKey, _isOfflineModeEnabled);
    notifyListeners();

    if (_isOfflineModeEnabled) {
      // Placeholder for download logic
      print("Offline mode enabled. Starting downloads...");
      // TODO: Implement actual download logic for favorites and playlists
      // TODO: Implement progress notification
    } else {
      print("Offline mode disabled.");
      // TODO: Optionally, implement logic to clear downloaded content or ask user
    }
  }

  // Placeholder for download methods
  Future<void> downloadFavorites() async {
    // TODO: Get favorite songs and download them
  }

  Future<void> downloadPlaylists() async {
    // TODO: Get saved playlists and download their songs
  }

  // Placeholder for notification logic
  void showDownloadProgressNotification(int downloaded, int total) {
    // TODO: Implement a notification (e.g., using flutter_local_notifications)
    // or update UI with progress.
    print("Downloading: $downloaded/$total");
  }
}