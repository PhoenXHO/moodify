import 'package:emotion_music_player/viewmodels/favorites_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emotion_music_player/widgets/song_list_widget.dart';
import 'package:emotion_music_player/widgets/snackbar.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  @override
  void initState() {
    super.initState();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesViewModel>(context, listen: false).fetchFavorites();
    });
  }

  @override
  void dispose() {
    // Clean up unfavorited songs when leaving the screen
    Provider.of<FavoritesViewModel>(context, listen: false).cleanupUnfavoritedSongs();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FavoritesViewModel>(
        builder: (context, viewmodel, child) {
          if (viewmodel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showSnackBar(context, viewmodel.errorMessage!);
            });
          }

          return RefreshIndicator(
            onRefresh: () => viewmodel.fetchFavorites(),
            child: SongListWidget(
                songs: viewmodel.favoriteSongs,
                isLoading: viewmodel.isLoading,
                onFavoriteToggle: viewmodel.toggleFavorite
            ),
          );
        },
      ),
    );
  }
}