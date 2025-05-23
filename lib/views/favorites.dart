import 'package:emotion_music_player/viewmodels/favorites_viewmodel.dart';
import 'package:emotion_music_player/views/search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emotion_music_player/widgets/song_list_widget.dart';
import 'package:emotion_music_player/widgets/snackbar.dart';
import 'package:emotion_music_player/theme/app_colors.dart';
import '../theme/dimensions.dart';
import '../viewmodels/favorites_viewmodel.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with AutomaticKeepAliveClientMixin {
  late FavoritesViewModel _favoritesViewModel;

  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  @override
  void initState() {
    super.initState();
    // Store a reference to the FavoritesViewModel
    _favoritesViewModel = Provider.of<FavoritesViewModel>(context, listen: false);

    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesViewModel>(context, listen: false).fetchFavorites();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update the reference to the FavoritesViewModel
    _favoritesViewModel = Provider.of<FavoritesViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    // Clean up unfavorited songs when leaving the screen
    _favoritesViewModel.cleanupUnfavoritedSongsSilently();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Favorites'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: false, // Remove back button
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: Dimensions.iconSize),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(initialQuery: ''),
                ),
              );
            },
          ),
        ],
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
                onFavoriteToggle: (song) {
                  viewmodel.toggleFavorite(song.id);
                },
                isFavoritesContext: true // Added: Set to true for FavoritesScreen
                ),
          );
        },
      ),
    );
  }
}