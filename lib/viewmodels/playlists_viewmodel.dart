import 'package:emotion_music_player/repositories/song_repository.dart';
import 'package:flutter/material.dart';
import 'package:emotion_music_player/models/playlist.dart';
import 'package:emotion_music_player/models/song.dart';
import 'package:emotion_music_player/repositories/playlist_repository.dart';
import 'package:emotion_music_player/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlaylistsViewModel extends ChangeNotifier {
  final PlaylistRepository _playlistRepository = PlaylistRepository();
  final AuthRepository _authRepository = AuthRepository();
  final SongRepository _songRepository = SongRepository();

  // Add tracking for current playlist
  String? _currentPlaylistId;
  String? get currentPlaylistId => _currentPlaylistId;

  SupabaseClient get supabase => Supabase.instance.client;
  // Add a getter or field for songs
  List<Song> _songs = []; // Replace with actual initialization logic
  List<Song> get songs => _songs;
  List<Playlist> _playlists = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all playlists
  Future<void> fetchPlaylists() async {
    _isLoading = true; // This is for initial load, keep it.
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _authRepository.getCurrentUser();
      print('Current user: ${user?.id}'); // Debug user

      if (user == null) {
        _errorMessage = 'You need to login to view playlists';
        return;
      }

      final fetchedPlaylists =
          await _playlistRepository.getUserPlaylists(user.id);
      print('Fetched playlists: ${fetchedPlaylists.length}'); // Debug playlists

      _playlists = fetchedPlaylists;
      print(
          'Updated state playlists: ${_playlists.length}'); // Debug state update
    } catch (e) {
      print('Error in fetchPlaylists: $e'); // Debug error
      _errorMessage = 'Error fetching playlists: $e';
    } finally {
      _isLoading = false; // End of initial load.
      notifyListeners();
    }
  }

  Future<Playlist?> createPlaylist(String name, String description) async { // Return type changed to Playlist? for error handling
    // _isLoading = true; // Remove global loading for this action
    // _errorMessage = null;
    // notifyListeners();

    try {
      final user = _authRepository.getCurrentUser();
      if (user == null) {
        _errorMessage = 'You need to login to create playlists';
        notifyListeners();
        return null;
      }
      final response = await supabase
          .from('playlists')
          .insert({
            'title': name,
            'description': description,
            'user_id': user.id, // Use user.id directly
          })
          .select()
          .single();

      final playlist = Playlist.fromJson(response);
      _playlists.add(playlist);
      notifyListeners(); // Update UI without global loader
      return playlist;
    } catch (e) {
      _errorMessage = 'Error creating playlist: $e';
      notifyListeners(); // Show error without global loader
      return null; // Return null on error
    }
    // finally {
    //   _isLoading = false; // Remove global loading for this action
    //   notifyListeners();
    // }
  }

  // Create playlist with songs (for AI-generated playlists)
  Future<String?> createPlaylistWithSongs({
    required String title,
    String? description,
    required List<String> songIds,
  }) async {
    try {
      final user = _authRepository.getCurrentUser();
      if (user == null) {
        _errorMessage = 'You need to login to create playlists';
        notifyListeners();
        return null;
      }

      final playlistId = await _playlistRepository.createPlaylist(
        userId: user.id,
        title: title,
        description: description,
        songIds: songIds,
      );

      print(
          'Playlist created with ID: $playlistId and ${songIds.length} songs');
      await fetchPlaylists(); // Refresh the playlists list
      return playlistId;
    } catch (e) {
      print('Error in createPlaylistWithSongs: $e');
      _errorMessage = 'Error creating playlist: $e';
      notifyListeners();
      return null;
    }
  }

  // Load songs for a specific playlist
  Future<void> loadPlaylistSongs(String playlistId) async {
    _isLoading = true; // This is for initial load of a specific playlist's content, keep it.
    _errorMessage = null;
    _currentPlaylistId = playlistId;
    notifyListeners();

    try {
      final user = _authRepository.getCurrentUser();
      final playlistSongs =
          await _playlistRepository.getPlaylistSongs(playlistId);

      if (user != null) {
        final favorites = await _songRepository.getFavorites(user.id);
        final favoriteIds = favorites.map((song) => song.id).toSet();

        for (var song in playlistSongs) {
          song.isFavorite = favoriteIds.contains(song.id);
        }
      }

      // Update the playlist with the loaded songs
      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        _playlists[index] = _playlists[index].copyWith(songs: playlistSongs);
      }
    } catch (e) {
      _errorMessage = 'Error loading playlist songs: $e';
    } finally {
      _isLoading = false; // End of specific playlist load.
      notifyListeners();
    }
  }  // Get songs for a specific playlist
  List<Song> getPlaylistSongs(String playlistId) {
    try {
      final playlist = _playlists.firstWhere((p) => p.id == playlistId);
      return playlist.songs;
    } catch (e) {
      // If playlist is not found, return an empty list
      print('Playlist with ID $playlistId not found in playlists list');
      // Don't call loadPlaylistSongs directly from here as it might be during build
      // Schedule it for after the current build completes
      Future.microtask(() => loadPlaylistSongs(playlistId));
      return [];
    }
  }

  // Update playlist details
  Future<bool> updatePlaylist(
      String playlistId, String title, String? description) async {
    // _isLoading = true; // Remove global loading
    // _errorMessage = null;
    // notifyListeners();

    try {
      await _playlistRepository.updatePlaylist(
        playlistId: playlistId,
        title: title,
        description: description,
      );
      // Instead of full fetch, update local list and notify
      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        _playlists[index] = _playlists[index].copyWith(title: title, description: description);
      }
      notifyListeners(); // Update UI without global loader
      return true;
    } catch (e) {
      _errorMessage = 'Error updating playlist: $e';
      notifyListeners(); // Show error without global loader
      return false;
    }
    // finally {
    //   _isLoading = false; // Remove global loading
    //   notifyListeners();
    // }
  }

  // Delete playlist
  Future<bool> deletePlaylist(String playlistId) async {
    // _isLoading = true; // Remove global loading
    // _errorMessage = null;
    // notifyListeners();

    try {
      await _playlistRepository.deletePlaylist(playlistId);
      _playlists.removeWhere((p) => p.id == playlistId);
      notifyListeners(); // Update UI without global loader
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting playlist: $e';
      notifyListeners(); // Show error without global loader
      return false;
    }
    // finally {
    //   _isLoading = false; // Remove global loading
    //   notifyListeners();
    // }
  }

  // Remove song from playlist
  Future<bool> removeSongFromPlaylist(String playlistId, String songId) async {
    // _isLoading = true; // Remove global loading for this action
    // _errorMessage = null;
    // notifyListeners();

    try {
      await _playlistRepository.removeSongFromPlaylist(playlistId, songId);
      // Instead of full reload, update the specific playlist's song list
      final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex != -1) {
        final updatedSongs = List<Song>.from(_playlists[playlistIndex].songs)
          ..removeWhere((s) => s.id == songId);
        _playlists[playlistIndex] = _playlists[playlistIndex].copyWith(songs: updatedSongs);
      }
      notifyListeners(); // Update UI without global loader
      return true;
    } catch (e) {
      _errorMessage = 'Error removing song: $e';
      notifyListeners(); // Show error without global loader
      return false;
    }
    // finally {
    //   _isLoading = false; // Remove global loading for this action
    //   notifyListeners();
    // }
  }

  // Reorder songs in playlist
  Future<void> reorderSongs(
      String playlistId, int oldIndex, int newIndex) async {
    // No global _isLoading change here, reordering should be quick and UI updates locally.
    try {
      final playlist = _playlists.firstWhere((p) => p.id == playlistId);
      final songs = playlist.songs;

      // Store the original order for rollback if needed
      final originalOrder = List<Song>.from(songs);

      // Update the local order first
      final song = songs.removeAt(oldIndex);
      songs.insert(newIndex, song);

      // Create the updates for the database
      final updates = songs
          .asMap()
          .entries
          .map((entry) => {
                'song_id': entry.value.id,
                'position': entry.key,
              })
          .toList();

      // Optimistically update the UI
      notifyListeners();

      try {
        // Then update the database
        await _playlistRepository.updateSongPositions(playlistId, updates);
      } catch (e) {
        // If database update fails, revert to original order
        final index = _playlists.indexWhere((p) => p.id == playlistId);
        if (index != -1) {
          _playlists[index] = _playlists[index].copyWith(songs: originalOrder);
        }
        throw e; // Re-throw to be caught by outer try-catch
      }
    } catch (e) {
      _errorMessage = 'Error reordering songs: $e';
      notifyListeners();
    }
  }

  // Add a single song to playlist
  Future<bool> addSongToPlaylist(String playlistId, String songId) async {
    // _isLoading = true; // Remove global loading
    // _errorMessage = null;
    // notifyListeners();

    try {
      // Fetch the song details first to add to the local list
      final song = await _songRepository.getSongById(songId); 
      if (song == null) {
        _errorMessage = 'Error: Song not found to add to playlist.';
        notifyListeners();
        return false;
      }

      await supabase.from('playlist_songs').insert({
        'playlist_id': playlistId,
        'song_id': songId,
        'position': getPlaylistSongs(playlistId).length, // Add at the end
      });

      // Update local playlist's song list
      final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex != -1) {
        final updatedSongs = List<Song>.from(_playlists[playlistIndex].songs)..add(song);
        _playlists[playlistIndex] = _playlists[playlistIndex].copyWith(songs: updatedSongs);
      }
      notifyListeners(); // Update UI without global loader
      return true;
    } catch (e) {
      _errorMessage = 'Error adding song to playlist: $e';
      notifyListeners(); // Show error without global loader
      return false;
    }
    // finally {
    //   _isLoading = false; // Remove global loading
    //   notifyListeners();
    // }
  }

  Future<void> addSongsToPlaylist(
      String playlistId, List<String> songIds) async {
    // _isLoading = true; // Remove global loading
    // _errorMessage = null;
    // notifyListeners();

    try {
      // Get current position
      final currentPosition = getPlaylistSongs(playlistId).length;
      List<Song> addedSongsDetails = [];

      // Create entries for each song
      final entries = await Future.wait(songIds.asMap().entries.map((entry) async {
        final songDetail = await _songRepository.getSongById(entry.value);
        if (songDetail != null) addedSongsDetails.add(songDetail);
        return {
          'playlist_id': playlistId,
          'song_id': entry.value,
          'position': currentPosition + entry.key,
        };
      }).toList());

      // Add all songs at once
      await supabase.from('playlist_songs').insert(entries);

      // Update local playlist's song list
      final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex != -1) {
        final updatedSongs = List<Song>.from(_playlists[playlistIndex].songs)..addAll(addedSongsDetails);
        _playlists[playlistIndex] = _playlists[playlistIndex].copyWith(songs: updatedSongs);
      }
      notifyListeners(); // Update UI without global loader
    } catch (e) {
      _errorMessage = 'Error adding songs to playlist: $e';
      notifyListeners(); // Show error without global loader
      throw e; // Re-throw for the caller to handle if needed
    }
    // finally {
    //   _isLoading = false; // Remove global loading
    //   notifyListeners();
    // }
  }

  void clearError() {
    // Logic to clear the error message
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // load all songs
  Future<List<Song>> getAllSongs(String playlistId) async {
    try {
      _isLoading = true;

      final user = _authRepository.getCurrentUser();
      if (user == null) {
        _errorMessage = 'You need to login to view songs';
        _isLoading = false;
        notifyListeners();
        return [];
      }

      // Get all songs from the repository
      final allSongs = await _songRepository.getAllSongs();

      // Get songs already in the playlist
      final playlistSongs =
          await _playlistRepository.getPlaylistSongs(playlistId);
      final playlistSongIds = playlistSongs.map((song) => song.id).toSet();

      // Filter out songs already in the playlist
      _songs =
          allSongs.where((song) => !playlistSongIds.contains(song.id)).toList();

      // Apply favorite status if user is logged in
      final favorites = await _songRepository.getFavorites(user.id);
      final favoriteIds = favorites.map((song) => song.id).toSet();

      for (var song in _songs) {
        song.isFavorite = favoriteIds.contains(song.id);
      }

      _isLoading = false;
      notifyListeners();
      return _songs;
    } catch (e) {
      _errorMessage = 'Error fetching all songs: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
}
