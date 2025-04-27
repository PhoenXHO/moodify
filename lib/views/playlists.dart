import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emotion_music_player/viewmodels/playlists_viewmodel.dart';
import 'package:emotion_music_player/models/playlist.dart';
import 'package:emotion_music_player/widgets/snackbar.dart';
import 'package:emotion_music_player/views/playlist_contents.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> 
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlaylistsViewModel>(context, listen: false).fetchPlaylists();
    });
  }

  Future<void> _createPlaylist() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Playlist Name',
                hintText: 'Enter playlist name'
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Enter playlist description'
              ),
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
                  .createPlaylist(nameController.text, descriptionController.text);
              
              if (success && mounted) {
                Navigator.pop(context);
                showSnackBar(context, 'Playlist created successfully');
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  super.build(context);

  return Scaffold(
    appBar: AppBar(
      title: const Text('My Playlists'),
      centerTitle: true,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _createPlaylist,
        ),
      ],
    ),
    body: Consumer<PlaylistsViewModel>(
      builder: (context, viewModel, child) {
        print('Building playlist view with ${viewModel.playlists.length} playlists'); // Debug UI

        if (viewModel.errorMessage != null) {
          print('Error message: ${viewModel.errorMessage}'); // Debug error
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showSnackBar(context, viewModel.errorMessage!);
          });
        }

        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.playlists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No playlists yet',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _createPlaylist,
                  child: const Text('Create Playlist'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => viewModel.fetchPlaylists(),
          child: ListView.builder(
            itemCount: viewModel.playlists.length,
            itemBuilder: (context, index) {
              final playlist = viewModel.playlists[index];
              return ListTile(
                title: Text(playlist.title),
                subtitle: Text(
                  playlist.description ?? '${playlist.songCount} songs',
                ),
                leading: const Icon(Icons.queue_music),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showPlaylistOptions(context, playlist),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaylistDetailScreen(playlist: playlist),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    ),
  );
}

  void _showPlaylistOptions(BuildContext context, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Playlist'),
              onTap: () {
                Navigator.pop(context);
                _editPlaylist(playlist);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Playlist'),
              onTap: () {
                Navigator.pop(context);
                _deletePlaylist(playlist.id);
              },
            ),
          ],
        ),
      ),
    );
  }
  void _editPlaylist(Playlist playlist) {
    final TextEditingController nameController = TextEditingController(text: playlist.title);
    final TextEditingController descriptionController = TextEditingController(text: playlist.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Playlist Name',
                hintText: 'Enter playlist name'
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Enter playlist description'
              ),
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
                  .updatePlaylist(playlist.id, nameController.text, descriptionController.text);
              
              if (success && mounted) {
                Navigator.pop(context);
                showSnackBar(context, 'Playlist updated successfully');
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
  void _deletePlaylist(String playlistId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: const Text('Are you sure you want to delete this playlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await Provider.of<PlaylistsViewModel>(context, listen: false)
                  .deletePlaylist(playlistId);
              
              if (success && mounted) {
                Navigator.pop(context);
                showSnackBar(context, 'Playlist deleted successfully');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}