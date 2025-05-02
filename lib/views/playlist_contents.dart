import 'package:emotion_music_player/models/song.dart';
import 'package:emotion_music_player/viewmodels/favorites_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emotion_music_player/models/playlist.dart';
import 'package:emotion_music_player/viewmodels/playlists_viewmodel.dart';
import 'package:emotion_music_player/widgets/song_list_widget.dart';
import 'package:emotion_music_player/widgets/snackbar.dart';
import 'package:emotion_music_player/views/screens/song_selection_screen.dart'
    as song_selection;

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
    // Load playlist songs when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlaylistsViewModel>(context, listen: false)
          .loadPlaylistSongs(widget.playlist.id);
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
      appBar: AppBar(
        title: Text(widget.playlist.title),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editPlaylist,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deletePlaylist,
          ),
        ],
      ),
      body: Consumer<PlaylistsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showSnackBar(context, viewModel.errorMessage!);
              viewModel.clearError();
            });
          }

          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final songs = viewModel.getPlaylistSongs(widget.playlist.id);

          return Column(
            children: [
              // Playlist info section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black87,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${songs.length} ${songs.length == 1 ? 'song' : 'songs'}',
                      style: const TextStyle(
                        color: Colors.white,
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
              ),
              // Songs list with reordering
              Expanded(
                child: SongListWidget(
                  songs: viewModel.getPlaylistSongs(widget.playlist.id),
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
        child: const Icon(Icons.add),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Playlist Name'),
            ),
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final viewModel =
                  Provider.of<PlaylistsViewModel>(context, listen: false);
              viewModel.updatePlaylist(
                widget.playlist.id,
                nameController.text,
                descriptionController.text,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final viewModel =
                  Provider.of<PlaylistsViewModel>(context, listen: false);
              final success =
                  await viewModel.deletePlaylist(widget.playlist.id);

              if (success && mounted) {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to playlists screen
                showSnackBar(context, 'Playlist deleted successfully');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _removeSong(String songId) async {
    final viewModel = Provider.of<PlaylistsViewModel>(context, listen: false);
    final success =
        await viewModel.removeSongFromPlaylist(widget.playlist.id, songId);

    if (success) {
      // Refresh the playlist songs to reflect the removal
      viewModel.loadPlaylistSongs(widget.playlist.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Song removed from playlist')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove song from playlist')),
      );
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

  void addSongToPlaylist(String playlistId, String songId) {
    final viewModel = Provider.of<PlaylistsViewModel>(context, listen: false);
    viewModel.addSongToPlaylist(playlistId, songId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Song added to playlist')),
    );
  }
}
