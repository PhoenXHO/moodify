import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emotion_music_player/models/playlist.dart';
import 'package:emotion_music_player/viewmodels/playlists_viewmodel.dart';
import 'package:emotion_music_player/widgets/song_list_widget.dart';
import 'package:emotion_music_player/widgets/snackbar.dart';

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
            });
          }

          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final songs = viewModel.getPlaylistSongs(widget.playlist.id);

          if (songs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No songs in this playlist',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addSongs,
                    child: const Text('Add Songs'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Playlist info section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black87,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${songs.length} songs',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
                child: ReorderableListView.builder(
                  itemCount: songs.length,
                  onReorder: (oldIndex, newIndex) {
                    viewModel.reorderSongs(
                      widget.playlist.id,
                      oldIndex,
                      newIndex > oldIndex ? newIndex - 1 : newIndex,
                    );
                  },
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return ListTile(
                      key: ValueKey(song.id),
                      title: Text(song.title),
                      subtitle: Text(song.artist),
                      leading: const Icon(Icons.music_note),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removeSong(song.id),
                      ),
                    );
                  },
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
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                showSnackBar(context, 'Please enter a playlist name');
                return;
              }

              final success = await Provider.of<PlaylistsViewModel>(context, listen: false)
                  .updatePlaylist(
                    widget.playlist.id,
                    nameController.text,
                    descriptionController.text,
                  );

              if (success && mounted) {
                Navigator.pop(context);
                showSnackBar(context, 'Playlist updated successfully');
              }
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
        content: Text('Are you sure you want to delete "${widget.playlist.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await Provider.of<PlaylistsViewModel>(context, listen: false)
                  .deletePlaylist(widget.playlist.id);

              if (success && mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to playlists screen
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

  void _addSongs() {
    // TODO: Implement add songs functionality
    // This will be implemented when we create the song selection screen
    showSnackBar(context, 'Add songs functionality coming soon');
  }

  void _removeSong(String songId) {
    Provider.of<PlaylistsViewModel>(context, listen: false)
        .removeSongFromPlaylist(widget.playlist.id, songId);
  }
}