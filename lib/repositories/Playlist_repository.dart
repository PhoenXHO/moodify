import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:emotion_music_player/models/playlist.dart';
import 'package:emotion_music_player/models/song.dart';

class PlaylistRepository {
  final _supabase = Supabase.instance.client;

  // Get all playlists for a user
  Future<List<Playlist>> getUserPlaylists(String userId) async {
    try {
      print('Fetching playlists for user: $userId'); // Debug user ID

      final response = await _supabase
          .from('playlists')
          .select('*')  // Simplified query first
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('Raw Supabase response: $response'); // Debug response

      return (response as List).map((data) => Playlist.fromJson(data)).toList();
    } catch (e) {
      print('Error in getUserPlaylists: $e'); // Debug error
      throw 'Failed to fetch playlists: $e';
    }
}

  // Create a new playlist
  Future<void> createPlaylist({
    required String userId,
    required String title,
    String? description,
  }) async {
    try {
      await _supabase.from('playlists').insert({
        'user_id': userId,
        'title': title,
        'description': description,
        'is_public': false,
        'song_count': 0,
      });
    } catch (e) {
      throw 'Failed to create playlist: $e';
    }
  }

  // Delete a playlist
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _supabase
          .from('playlists')
          .delete()
          .eq('id', playlistId);
    } catch (e) {
      throw 'Failed to delete playlist: $e';
    }
  }

  // Update playlist details
  Future<void> updatePlaylist({
    required String playlistId,
    required String title,
    String? description,
  }) async {
    try {
      await _supabase
          .from('playlists')
          .update({
            'title': title,
            'description': description,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', playlistId);
    } catch (e) {
      throw 'Failed to update playlist: $e';
    }
  }

  // Get songs in a playlist
  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    try {
      final response = await _supabase
          .from('playlist_songs')
          .select('songs(*)')
          .eq('playlist_id', playlistId)
          .order('position');

      return (response as List)
          .map((data) => Song.fromJson(data['songs']))
          .toList();
    } catch (e) {
      throw 'Failed to fetch playlist songs: $e';
    }
  }

  // Add a song to a playlist
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    try {
      // Get current highest position
      final response = await _supabase
          .from('playlist_songs')
          .select('position')
          .eq('playlist_id', playlistId)
          .order('position', ascending: false)
          .limit(1);

      final position = response.isEmpty ? 0 : response[0]['position'] + 1;

      await _supabase.from('playlist_songs').insert({
        'playlist_id': playlistId,
        'song_id': songId,
        'position': position,
      });

      // Update song count
      await _updateSongCount(playlistId);
    } catch (e) {
      throw 'Failed to add song to playlist: $e';
    }
  }

  // Remove a song from a playlist
  Future<void> removeSongFromPlaylist(
    String playlistId,
    String songId,
  ) async {
    try {
      await _supabase
          .from('playlist_songs')
          .delete()
          .eq('playlist_id', playlistId)
          .eq('song_id', songId);

      // Update song count
      await _updateSongCount(playlistId);
    } catch (e) {
      throw 'Failed to remove song from playlist: $e';
    }
  }

  // Update song positions in a playlist
  Future<void> updateSongPositions(
    String playlistId,
    List<Map<String, dynamic>> updates,
  ) async {
    try {
      for (final update in updates) {
        await _supabase
            .from('playlist_songs')
            .update({'position': update['position']})
            .eq('playlist_id', playlistId)
            .eq('song_id', update['song_id']);
      }
    } catch (e) {
      throw 'Failed to update song positions: $e';
    }
  }

  // Helper method to update song count
  Future<void> _updateSongCount(String playlistId) async {
    try {
      final count = await _supabase
          .from('playlist_songs')
          .select('id')
          .eq('playlist_id', playlistId);

      await _supabase
          .from('playlists')
          .update({'song_count': count.length})
          .eq('id', playlistId);
    } catch (e) {
      throw 'Failed to update song count: $e';
    }
  }
}