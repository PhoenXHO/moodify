import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/song.dart';

class SongRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Song>> getFavorites(String userId) async {
    final response = await _supabase
        .from('favorites')
        .select('song_id, songs(*)')
        .eq('user_id', userId);

    List<Song> songs = [];
    for (var item in response) {
      try {
        final songData = item['songs'];
        songData['is_favorite'] = true; // Mark as favorite
        songs.add(Song.fromJson(songData));
      } catch (e) {
        print('Error parsing song: $e');
      }
    }

    return songs;
  }

  Future<bool> toggleFavorite(String userId, String songId) async {
    try {
      final response = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('song_id', songId);

      // If the song is already a favorite, remove it, otherwise add it
      if (response.isNotEmpty) {
        await _supabase
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('song_id', songId);
      } else {
        await _supabase
            .from('favorites')
            .insert({'user_id': userId, 'song_id': songId});
      }

      return true;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }
}