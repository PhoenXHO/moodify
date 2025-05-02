import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:emotion_music_player/models/playlist.dart';
import 'package:emotion_music_player/models/song.dart';

class PlaylistRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Playlist>> getUserPlaylists(String userId) async {
    try {
      final response = await _supabase
          .from('playlists')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((data) => Playlist.fromJson(data)).toList();
    } catch (e) {
      throw 'Failed to fetch playlists: $e';
    }
  }

  Future<String> createPlaylist({
    required String userId,
    required String title,
    String? description,
    List<String>? songIds,
  }) async {
    try {
      final response = await _supabase
          .from('playlists')
          .insert({
            'user_id': userId,
            'title': title,
            'description': description,
            'is_public': false,
            'song_count': songIds?.length ?? 0,
          })
          .select('id')
          .single();

      final playlistId = response['id'];

      if (songIds != null && songIds.isNotEmpty) {
        final playlistSongEntries = songIds
            .asMap()
            .entries
            .map((entry) => {
                  'playlist_id': playlistId,
                  'song_id': entry.value,
                  'position': entry.key,
                })
            .toList();

        await _supabase.from('playlist_songs').insert(playlistSongEntries);
      }

      return playlistId;
    } catch (e) {
      throw 'Failed to create playlist: $e';
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _supabase.from('playlists').delete().eq('id', playlistId);
    } catch (e) {
      throw 'Failed to delete playlist: $e';
    }
  }

  Future<void> updatePlaylist({
    required String playlistId,
    required String title,
    String? description,
  }) async {
    try {
      await _supabase.from('playlists').update({
        'title': title,
        'description': description,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', playlistId);
    } catch (e) {
      throw 'Failed to update playlist: $e';
    }
  }

  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    try {
      final result = await _supabase
          .from('playlist_songs')
          .select('songs(*), position')
          .eq('playlist_id', playlistId)
          .order('position');

      return (result as List)
          .map((item) => Song.fromJson(item['songs']))
          .toList();
    } catch (e) {
      throw 'Failed to fetch playlist songs: $e';
    }
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    try {
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

      await _updateSongCount(playlistId);
    } catch (e) {
      throw 'Failed to add song to playlist: $e';
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      if (playlistId.isEmpty || songId.isEmpty) {
        throw 'Invalid playlistId or songId';
      }

      final preCheckResponse = await _supabase
          .from('playlist_songs')
          .select()
          .eq('playlist_id', playlistId)
          .eq('song_id', songId);

      if (preCheckResponse == null || preCheckResponse.isEmpty) {
        throw 'Row does not exist in playlist_songs table';
      }

      final response = await _supabase
          .from('playlist_songs')
          .delete()
          .eq('playlist_id', playlistId)
          .eq('song_id', songId)
          .select();

      if (response == null || response.isEmpty) {
        throw 'Failed to remove song: No rows affected';
      }

      await _updateSongCount(playlistId);

      // Trigger playlist refresh (callback or state update)
      await getPlaylistSongs(playlistId); // Refresh playlist songs
    } catch (e) {
      throw 'Failed to remove song from playlist: $e';
    }
  }

  Future<void> updateSongPositions(
      String playlistId, List<Map<String, dynamic>> updates) async {
    final playlistSongsResponse = await _supabase
        .from('playlist_songs')
        .select('id, song_id')
        .eq('playlist_id', playlistId);

    for (var update in updates) {
      final String songId = update['song_id'];
      final int position = update['position'];

      final entry = playlistSongsResponse.firstWhere(
        (item) => item['song_id'] == songId,
        orElse: () => <String, dynamic>{},
      );
      if (entry.isNotEmpty) {
        await _supabase
            .from('playlist_songs')
            .update({'position': position}).eq('id', entry['id']);
      }
    }
  }

  Future<void> _updateSongCount(String playlistId) async {
    try {
      final count = await _supabase
          .from('playlist_songs')
          .select('id')
          .eq('playlist_id', playlistId);

      await _supabase
          .from('playlists')
          .update({'song_count': count.length}).eq('id', playlistId);
    } catch (e) {
      throw 'Failed to update song count: $e';
    }
  }
}
