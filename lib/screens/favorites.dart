import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:emotion_music_player/models/song.dart';
import 'package:emotion_music_player/widgets/song_list_widget.dart';
import 'package:emotion_music_player/widgets/snackbar.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final supabase = Supabase.instance.client;
  List<Song> favoriteSongs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        showSnackBar(context, 'You need to login to view favorites');
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Fetch favorites for current user with song details using a join
      final response = await supabase
          .from('favorites')
          .select('song_id, songs(*)')
          .eq('user_id', user.id);

      List<Song> songs = [];
      for (var item in response) {
        final songData = item['songs'];
        songData['is_favorite'] = true; // Mark as favorite
        
        // Parse genres and moods if they're strings instead of JSONB
        try {
          if (songData['genres'] is String) {
            songData['genres'] = songData['genres'];
          }
          if (songData['moods'] is String) {
            songData['moods'] = songData['moods'];
          }
          final song = Song.fromJson(songData);
          songs.add(song);
        } catch (e) {
          print('Error parsing song: $e');
        }
      }

      setState(() {
        favoriteSongs = songs;
      });
    } catch (e) {
      showSnackBar(context, 'Error loading favorites: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleFavoriteToggle(String songId, bool isFavorite) {
    setState(() {
      if (!isFavorite) {
        // Remove from local list if unfavorited
        favoriteSongs.removeWhere((song) => song.id == songId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchFavorites,
        child: SongListWidget(
          songs: favoriteSongs,
          isLoading: isLoading,
          onFavoriteToggle: _handleFavoriteToggle,
        ),
      ),
    );
  }
}