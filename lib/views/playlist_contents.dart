import 'package:emotion_music_player/models/song.dart';
import 'package:emotion_music_player/viewmodels/favorites_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emotion_music_player/models/playlist.dart';
import 'package:emotion_music_player/viewmodels/playlists_viewmodel.dart';
import 'package:emotion_music_player/widgets/song_list_widget.dart';
import 'package:emotion_music_player/widgets/snackbar.dart';
import 'package:emotion_music_player/views/song_selection_screen.dart'
    as song_selection;
import 'package:emotion_music_player/theme/dimensions.dart';
import 'package:emotion_music_player/theme/app_colors.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  FavoritesViewModel?
      _favoritesViewModel; // Store a reference to the FavoritesViewModel
  @override
  void initState() {
    super.initState();
    // Load playlist songs when screen opens, with error handling
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final viewModel = Provider.of<PlaylistsViewModel>(context, listen: false);
        
        // First fetch all playlists to make sure we have the playlist in the view model
        await viewModel.fetchPlaylists();
        
        // Then load this specific playlist's songs
        await viewModel.loadPlaylistSongs(widget.playlist.id);
        
        print('Successfully loaded playlist ${widget.playlist.id} with songs');
      } catch (e) {
        print('Error loading playlist: $e');
        if (mounted) {
          showSnackBar(context, 'Error loading playlist: Please try again');
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save a reference to the FavoritesViewModel
    _favoritesViewModel ??=
        Provider.of<FavoritesViewModel>(context, listen: false);
    _favoritesViewModel?.addListener(_refreshPlaylistSongs);
  }

  @override
  void dispose() {
    // Use the stored reference instead of accessing Provider.of
    _favoritesViewModel?.removeListener(_refreshPlaylistSongs);
    super.dispose();
  }

  void _refreshPlaylistSongs() {
    // Reload playlist songs when favorites change
    if (mounted) {
      Provider.of<PlaylistsViewModel>(context, listen: false)
          .loadPlaylistSongs(widget.playlist.id);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.playlist.title),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, size: Dimensions.iconSize),
            onPressed: _editPlaylist,
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: Dimensions.iconSize),
            onPressed: _deletePlaylist,
          ),
        ],
      ),      body: Consumer<PlaylistsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.errorMessage != null && viewModel.currentPlaylistId == widget.playlist.id) { // Check if error is for current playlist
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showSnackBar(context, viewModel.errorMessage!);
              viewModel.clearError();
            });
          }
          
          // Show loader when loading songs for *this specific* playlist
          if (viewModel.isLoading && viewModel.currentPlaylistId == widget.playlist.id) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Get songs safely outside the build method's direct flow
          // Use the cached playlist from the view model directly to avoid triggering loads during build
          final songs = viewModel.playlists
              .firstWhere((p) => p.id == widget.playlist.id, 
                  orElse: () => widget.playlist).songs;

          return Column(
            children: [
              // Playlist info section
              Container(                padding: const EdgeInsets.all(16),
                color: AppColors.surface,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${songs.length} ${songs.length == 1 ? 'song' : 'songs'}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.playlist.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          widget.playlist.description!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),              // Songs list with reordering
              Expanded(
                child: SongListWidget(
                  songs: songs, // Use the songs we already safely retrieved above
                  isLoading: false, // We already checked loading state above
                  onFavoriteToggle: (Song song) {
                    Provider.of<FavoritesViewModel>(context, listen: false)
                        .toggleFavorite(song.id);
                  },
                  allowReordering: true,
                  onReorder: (oldIndex, newIndex) {
                    viewModel.reorderSongs(
                      widget.playlist.id,
                      oldIndex,
                      newIndex > oldIndex ? newIndex - 1 : newIndex,
                    );
                  },
                  onRemove: (song) =>
                      _removeSong(song), // Pass the correct callback
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSongs,
        child: const Icon(Icons.add, size: Dimensions.iconSize), // Use Dimensions
      ),
    );
  }

  void _editPlaylist() {
    final TextEditingController nameController = TextEditingController(
      text: widget.playlist.title,
    );
    final TextEditingController descriptionController = TextEditingController(
      text: widget.playlist.description,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Playlist Name'),
            ),
            const SizedBox(height: 16), // Added margin between fields
            TextField(
              controller: descriptionController,
              decoration:
                  const InputDecoration(labelText: 'Description (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
                'CANCEL',
                style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final viewModel =
                  Provider.of<PlaylistsViewModel>(context, listen: false);
              Navigator.of(context).pop(); // Close dialog first
              final success = await viewModel.updatePlaylist(
                widget.playlist.id,
                nameController.text,
                descriptionController.text,
              );
              if (success && mounted) {
                showSnackBar(context, 'Playlist updated successfully');
                // No need to manually update widget.playlist.title, viewmodel handles state
              } else if (mounted) {
                showSnackBar(context, 'Failed to update playlist. ${viewModel.errorMessage ?? ""}');
              }
            },
            child: const Text(
              'SAVE',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _deletePlaylist() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist'),
        content:
            Text('Are you sure you want to delete "${widget.playlist.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final viewModel =
                  Provider.of<PlaylistsViewModel>(context, listen: false);
              Navigator.of(context).pop(); // Close dialog first
              final success =
                  await viewModel.deletePlaylist(widget.playlist.id);

              if (success && mounted) {
                Navigator.of(context).pop(); // Return to playlists screen
                showSnackBar(context, 'Playlist deleted successfully');
              } else if (mounted) {
                showSnackBar(context, 'Failed to delete playlist. ${viewModel.errorMessage ?? ""}');
              }
            },
            child: const Text(
              'DELETE',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
  void _removeSong(String songId) async {
    // Get song details to show in confirmation dialog
    final viewModel = Provider.of<PlaylistsViewModel>(context, listen: false);
    final songs = viewModel.getPlaylistSongs(widget.playlist.id);
    final songToRemove = songs.firstWhere((song) => song.id == songId);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Remove Song',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to remove "${songToRemove.title}" from this playlist?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'CANCEL',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'REMOVE',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    // Continue with removal if confirmed
    // No dialog pop here, it was for confirmation
    final success =
        await viewModel.removeSongFromPlaylist(widget.playlist.id, songId);

    if (success && mounted) {
      // viewModel.loadPlaylistSongs(widget.playlist.id); // ViewModel updates list internally
      showSnackBar(context, 'Song removed from playlist');
    } else if (mounted) {
      showSnackBar(context, 'Failed to remove song. ${viewModel.errorMessage ?? ""}');
    }
  }

  void _addSongs() {
    // Navigate to the song selection screen using MaterialPageRoute instead of named route
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            song_selection.SongSelectionScreen(playlistId: widget.playlist.id),
      ),
    );
  }

  void addSongToPlaylist(String playlistId, String songId) async { // Made async
    final viewModel = Provider.of<PlaylistsViewModel>(context, listen: false);
    final success = await viewModel.addSongToPlaylist(playlistId, songId); // Await the operation
    if (success && mounted) {
      showSnackBar(context, 'Song added to playlist');
    } else if (mounted) {
      showSnackBar(context, 'Failed to add song. ${viewModel.errorMessage ?? ""}');
    }
  }
}
