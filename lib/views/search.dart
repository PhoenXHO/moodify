import 'package:emotion_music_player/models/song.dart';
import 'package:emotion_music_player/theme/app_colors.dart';
import 'package:emotion_music_player/theme/dimensions.dart';
import 'package:emotion_music_player/viewmodels/favorites_viewmodel.dart';
import 'package:emotion_music_player/viewmodels/player_viewmodel.dart';
import 'package:emotion_music_player/widgets/snackbar.dart';
import 'package:emotion_music_player/widgets/song_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/song_repository.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({
    super.key,
    this.initialQuery = '',
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SongRepository _songRepository = SongRepository();
  List<Song> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    if (widget.initialQuery.isNotEmpty) {
      _performSearch(widget.initialQuery);
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final userId = Provider.of<FavoritesViewModel>(context, listen: false).userId;
      final results = await _songRepository.searchSongs(
        query, 
        userId: userId,
        limit: 50, // Show more results in dedicated search screen
      );
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error searching for songs: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Songs'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          // Search input bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title, artist, genre or mood',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.borderRadius),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.borderRadius),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onSubmitted: (value) => _performSearch(value),
              textInputAction: TextInputAction.search,
            ),
          ),
          
          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          
          // Search results
          Expanded(
            child: _searchResults.isEmpty && !_isLoading
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'Enter a search term to find songs'
                          : 'No songs found matching "${_searchController.text}"',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : SongListWidget(
                    songs: _searchResults,
                    isLoading: _isLoading,
                    onFavoriteToggle: (song) {
                      Provider.of<FavoritesViewModel>(context, listen: false)
                          .toggleFavorite(song.id);
                      showSnackBar(
                        context,
                        song.isFavorite
                            ? 'Removed from favorites'
                            : 'Added to favorites',
                      );
                    },
                    isFavoritesContext: false,
                  ),
          ),
        ],
      ),
    );
  }
}
