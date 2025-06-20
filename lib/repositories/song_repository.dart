import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/song.dart';

class SongRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch basic metadata for all songs (for AI filtering step)
  Future<List<Map<String, dynamic>>> getAllSongsMetadata() async {
    try {
      final response = await _supabase
          .from('songs')
          .select('id, title, genres, moods, favorite_count');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching all songs metadata: $e');
      throw Exception('Failed to fetch song metadata');
    }
  }

  // Fetch songs, excluding specified moods/genres, ordered by favorites, limited
  Future<List<Song>> getFilteredSongs({
    List<String> excludeMoods = const [],
    List<String> excludeGenres = const [],
    int limit = 100, // Default limit for the second AI step
  }) async {
    try {
      var query = _supabase
          .from('songs')
          .select()
          .order('favorite_count', ascending: false)
          .limit(limit);

      // Apply filters only if the lists are not empty
      if (excludeMoods.isNotEmpty) {
        // Check if ANY mood in the song's 'moods' array is in 'excludeMoods'
        // Supabase uses @> for contains, so we need to negate it carefully.
        // We want songs where the 'moods' array does NOT contain ANY of the excludeMoods.
        // This is tricky with Supabase array functions directly.
        // A simpler approach might be to filter client-side after a broader fetch,
        // or use a database function. For now, let's fetch and filter client-side
        // or accept that this filtering might be less precise with basic operators.
        // Using 'cs' (contains) might work for individual items but not exclusion of multiple.
        // Let's fetch all within the limit and filter after. This is less efficient.
        // TODO: Revisit filtering logic for better efficiency (e.g., DB function or complex query)
      }
      if (excludeGenres.isNotEmpty) {
        // Similar challenge as with moods for exclusion.
      }

      final response = await query;

      List<Song> songs = response.map((data) => Song.fromJson(data)).toList();

      // Client-side filtering (less efficient but works for now)
      songs.removeWhere((song) {
        bool hasExcludedMood =
            excludeMoods.any((mood) => song.moods.contains(mood));
        bool hasExcludedGenre =
            excludeGenres.any((genre) => song.genres.contains(genre));
        return hasExcludedMood || hasExcludedGenre;
      });

      // Fetch favorite status separately (since it's user-specific)
      // This part is complex as we need the user ID. Assuming it's passed or handled elsewhere.
      // For now, returning without isFavorite status populated correctly from this method.
      // The getFavorites method handles this better.

      return songs;
    } catch (e) {
      print('Error fetching filtered songs: $e');
      throw Exception('Failed to fetch filtered songs');
    }
  }

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
      var song =
          await _supabase.from('songs').select().eq('id', songId).single();

      // If the song is already a favorite, remove it, otherwise add it
      if (response.isNotEmpty) {
        await _supabase
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('song_id', songId);
        // Update the song's favorite count
        await _supabase.from('songs').update({
          'favorite_count': max<int>(
              0, song['favorite_count'] - 1), // Ensure it doesn't go below 0
        }).eq('id', songId);
      } else {
        await _supabase
            .from('favorites')
            .insert({'user_id': userId, 'song_id': songId});
        // Update the song's favorite count
        await _supabase.from('songs').update({
          'favorite_count': song['favorite_count'] + 1,
        }).eq('id', songId);
      }

      return true;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  Future<List<Song>> getAllSongs() async {
    try {
      print("🎵 Song Repository: Starting to fetch songs");

      // Fix: Remove the execute() call and use the proper Supabase query format
      final response = await Supabase.instance.client
          .from('songs')
          .select(); // This returns all columns for all rows

      // Check if we got data
      if (response == null) {
        print("⚠️ Song Repository: No data returned");
        return [];
      }

      print(
          "✅ Song Repository: Raw song data received: ${response.length} items");

      // Convert JSON to Song objects
      final List<Song> songs = [];
      for (var songData in response) {
        try {
          final song = Song.fromJson(songData);
          songs.add(song);
          print("✅ Successfully parsed song: ${song.title}");
        } catch (e) {
          print("❌ Error parsing song: $e");
          print("❌ Problematic song data: $songData");
        }
      }

      print(
          "✅ Song Repository: Successfully converted ${songs.length} songs from JSON");
      return songs;
    } catch (e) {
      print("❌ Song Repository Error: $e");
      // Return empty list instead of throwing to prevent UI crashes
      return [];
    }
  }

  Future<Song?> getSongById(String songId) async {
    try {
      final response = await _supabase
          .from('songs')
          .select()
          .eq('id', songId)
          .maybeSingle(); // Use maybeSingle to handle cases where the song might not exist

      if (response == null) {
        print("⚠️ Song Repository: No song found with ID: $songId");
        return null;
      }
      return Song.fromJson(response);
    } catch (e) {
      print("❌ Song Repository Error fetching song by ID $songId: $e");
      return null;
    }
  }

  // Search songs by title, artist, genres, or moods with user-specific favorite status
  Future<List<Song>> searchSongs(String query, {String? userId, int limit = 20}) async {
    try {
      print("🔍 Song Repository: Searching for songs with query: '$query'");

      if (query.trim().isEmpty) {
        return await getAllSongs();
      }

      // Convert query to lowercase for case-insensitive search
      final lowerQuery = query.toLowerCase();

      // Get all songs and filter locally (more flexible than PostgreSQL ilike)
      final allSongs = await getAllSongs();

      // Get user favorites if userId is provided
      Set<String> favoriteIds = {};
      if (userId != null) {
        try {
          final favorites = await getFavorites(userId);
          favoriteIds = favorites.map((song) => song.id).toSet();
        } catch (e) {
          print("⚠️ Could not fetch favorites: $e");
        }
      }

      // Filter songs where title, artist, genres, or moods match the query
      final List<Song> matchingSongs = allSongs.where((song) {
        // Check title and artist (primary matches)
        final titleMatch = song.title.toLowerCase().contains(lowerQuery);
        final artistMatch = song.artist.toLowerCase().contains(lowerQuery);

        // Check genres and moods (secondary matches)
        final genreMatch = song.genres.any(
                (genre) => genre.toLowerCase().contains(lowerQuery)
        );
        final moodMatch = song.moods.any(
                (mood) => mood.toLowerCase().contains(lowerQuery)
        );

        return titleMatch || artistMatch || genreMatch || moodMatch;
      }).toList();

      // Mark favorite status if userId was provided
      if (userId != null) {
        for (var song in matchingSongs) {
          song.isFavorite = favoriteIds.contains(song.id);
        }
      }

      // Sort by relevance (title matches first, then artist, then others)
      matchingSongs.sort((a, b) {
        // Primary sort: Title matches
        final aTitleMatch = a.title.toLowerCase().contains(lowerQuery);
        final bTitleMatch = b.title.toLowerCase().contains(lowerQuery);

        if (aTitleMatch && !bTitleMatch) return -1;
        if (!aTitleMatch && bTitleMatch) return 1;

        // Secondary sort: Artist matches
        final aArtistMatch = a.artist.toLowerCase().contains(lowerQuery);
        final bArtistMatch = b.artist.toLowerCase().contains(lowerQuery);

        if (aArtistMatch && !bArtistMatch) return -1;
        if (!aArtistMatch && bArtistMatch) return 1;

        // Third sort: Favorite count
        return b.favoriteCount.compareTo(a.favoriteCount);
      });

      // Limit results
      final limitedResults = matchingSongs.take(limit).toList();

      print("✅ Song Repository: Found ${limitedResults.length} songs matching '$query'");
      return limitedResults;
    } catch (e) {
      print("❌ Song Repository Error during search: $e");
      return [];
    }
  }

  // Get all unique moods from the database
  Future<List<String>> getAllUniqueMoods() async {
    try {
      final allSongs = await getAllSongs();
      final Set<String> uniqueMoods = {};
      
      // Extract all moods from songs
      for (var song in allSongs) {
        uniqueMoods.addAll(song.moods);
      }
      
      return uniqueMoods.toList()..sort();
    } catch (e) {
      print("Error fetching unique moods: $e");
      return [];
    }
  }

  // Get all unique genres from the database
  Future<List<String>> getAllUniqueGenres() async {
    try {
      final allSongs = await getAllSongs();
      final Set<String> uniqueGenres = {};
      
      // Extract all genres from songs
      for (var song in allSongs) {
        uniqueGenres.addAll(song.genres);
      }
      
      return uniqueGenres.toList()..sort();
    } catch (e) {
      print("Error fetching unique genres: $e");
      return [];
    }
  }
}
