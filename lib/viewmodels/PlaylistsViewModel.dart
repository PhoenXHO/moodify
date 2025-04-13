import 'package:flutter/material.dart';
import 'package:emotion_music_player/models/playlist.dart';
import 'package:emotion_music_player/models/song.dart';
import 'package:emotion_music_player/repositories/playlist_repository.dart';
import 'package:emotion_music_player/repositories/auth_repository.dart';

class PlaylistsViewModel extends ChangeNotifier {
  final PlaylistRepository _playlistRepository = PlaylistRepository();
  final AuthRepository _authRepository = AuthRepository();

  List<Playlist> _playlists = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all playlists
  Future<void> fetchPlaylists() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _authRepository.getCurrentUser();
      print('Current user: ${user?.id}'); // Debug user

      if (user == null) {
        _errorMessage = 'You need to login to view playlists';
        return;
      }

      final fetchedPlaylists = await _playlistRepository.getUserPlaylists(user.id);
      print('Fetched playlists: ${fetchedPlaylists.length}'); // Debug playlists
      
      _playlists = fetchedPlaylists;
      print('Updated state playlists: ${_playlists.length}'); // Debug state update
    } catch (e) {
      print('Error in fetchPlaylists: $e'); // Debug error
      _errorMessage = 'Error fetching playlists: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
}

Future<bool> createPlaylist(String title, String? description) async {
    try {
      final user = _authRepository.getCurrentUser();
      if (user == null) {
        _errorMessage = 'You need to login to create playlists';
        notifyListeners();
        return false;
      }

      await _playlistRepository.createPlaylist(
        userId: user.id,
        title: title,
        description: description,
      );

      print('Playlist created, fetching updated list...'); // Debug create
      await fetchPlaylists(); // Explicitly fetch updated list
      return true;
    } catch (e) {
      print('Error in createPlaylist: $e'); // Debug error
      _errorMessage = 'Error creating playlist: $e';
      notifyListeners();
      return false;
    }
}


  // Load songs for a specific playlist
  Future<void> loadPlaylistSongs(String playlistId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final songs = await _playlistRepository.getPlaylistSongs(playlistId);
      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        _playlists[index] = _playlists[index].copyWith(songs: songs);
      }
    } catch (e) {
      _errorMessage = 'Error loading playlist songs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get songs for a specific playlist
  List<Song> getPlaylistSongs(String playlistId) {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    return playlist.songs;
  }

  // Create new playlist
  // Future<bool> createPlaylist(String title, String? description) async {
  //   try {
  //     final user = _authRepository.getCurrentUser();
  //     if (user == null) {
  //       _errorMessage = 'You need to login to create playlists';
  //       notifyListeners();
  //       return false;
  //     }

  //     await _playlistRepository.createPlaylist(
  //       userId: user.id,
  //       title: title,
  //       description: description,
  //     );

  //     await fetchPlaylists();
  //     return true;
  //   } catch (e) {
  //     _errorMessage = 'Error creating playlist: $e';
  //     notifyListeners();
  //     return false;
  //   }
  // }

  // Update playlist details
  Future<bool> updatePlaylist(String playlistId, String title, String? description) async {
    try {
      await _playlistRepository.updatePlaylist(
        playlistId: playlistId,
        title: title,
        description: description,
      );
      
      await fetchPlaylists();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating playlist: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete playlist
  Future<bool> deletePlaylist(String playlistId) async {
    try {
      await _playlistRepository.deletePlaylist(playlistId);
      _playlists.removeWhere((p) => p.id == playlistId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting playlist: $e';
      notifyListeners();
      return false;
    }
  }

  // Remove song from playlist
  Future<bool> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      await _playlistRepository.removeSongFromPlaylist(playlistId, songId);
      await loadPlaylistSongs(playlistId);
      return true;
    } catch (e) {
      _errorMessage = 'Error removing song: $e';
      notifyListeners();
      return false;
    }
  }

  // Reorder songs in playlist
  Future<void> reorderSongs(String playlistId, int oldIndex, int newIndex) async {
    try {
      final playlist = _playlists.firstWhere((p) => p.id == playlistId);
      final songs = playlist.songs;
      
      final song = songs.removeAt(oldIndex);
      songs.insert(newIndex, song);

      final updates = songs.asMap().entries.map((entry) => {
        'song_id': entry.value.id,
        'position': entry.key,
      }).toList();

      await _playlistRepository.updateSongPositions(playlistId, updates);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error reordering songs: $e';
      notifyListeners();
    }
  }
}   