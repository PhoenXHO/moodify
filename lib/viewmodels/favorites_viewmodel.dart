import 'package:emotion_music_player/models/song.dart';
import 'package:emotion_music_player/repositories/auth_repository.dart';
import 'package:emotion_music_player/repositories/song_repository.dart';
import 'package:flutter/material.dart';

class FavoritesViewModel extends ChangeNotifier {
  final SongRepository _songRepository = SongRepository();
  final AuthRepository _authRepository = AuthRepository();

  List<Song> _favoriteSongs = [];
  bool _isLoading = true;
  String? _errorMesssage;

  List<Song> get favoriteSongs => _favoriteSongs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMesssage;

  Future<void> fetchFavorites() async {
    _isLoading = true;
    _errorMesssage = null;
    notifyListeners(); // Notify listeners to update UI

    try {
      final user = _authRepository.getCurrentUser();
      if (user == null) {
        _errorMesssage = 'You need to login to view favorites';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _favoriteSongs = await _songRepository.getFavorites(user.id);
    } catch (e) {
      _errorMesssage = 'Error fetching favorites: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String songId) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      _errorMesssage = 'You need to login to add favorites';
      notifyListeners();
      return;
    }

    final songIndex = _favoriteSongs.indexWhere((song) => song.id == songId);
    
    try {
      if (songIndex >= 0) {
        // Song exists in favorites list - toggle its status
        _favoriteSongs[songIndex].isFavorite = !_favoriteSongs[songIndex].isFavorite;
        notifyListeners();
        
        final success = await _songRepository.toggleFavorite(user.id, songId);
        if (!success) {
          _errorMesssage = 'Failed to update favorite status. Please try again.';
          _favoriteSongs[songIndex].isFavorite = !_favoriteSongs[songIndex].isFavorite;
          notifyListeners();
        }
      } else {
        // Song is not in favorites list yet - add it
        final success = await _songRepository.toggleFavorite(user.id, songId);
        if (success) {
          // Refresh favorites to get the updated list
          await fetchFavorites();
        } else {
          _errorMesssage = 'Failed to add to favorites. Please try again.';
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMesssage = 'Error updating favorites: $e';
      notifyListeners();
    }
  }

  // Call this when leaving the favorites screen to remove unfavorited songs
  void cleanupUnfavoritedSongs() {
    _favoriteSongs.removeWhere((song) => !song.isFavorite);
    notifyListeners();
  }

  // Important for silent cleanup when navigating away from the favorites screen
  void cleanupUnfavoritedSongsSilently() {
    final songsToRemove = _favoriteSongs.where((song) => !song.isFavorite).toList();
    if (songsToRemove.isNotEmpty) {
      _favoriteSongs.removeWhere((song) => !song.isFavorite);
    }
  }
}