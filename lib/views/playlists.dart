import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emotion_music_player/viewmodels/playlists_viewmodel.dart';
import 'package:emotion_music_player/models/playlist.dart';
import 'package:emotion_music_player/widgets/snackbar.dart';
import 'package:emotion_music_player/views/playlist_contents.dart';
import 'package:emotion_music_player/views/search.dart';
import 'package:emotion_music_player/theme/app_colors.dart';
import 'package:emotion_music_player/theme/dimensions.dart';
import 'package:emotion_music_player/theme/text_styles.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save any required ancestor references here
  }

  @override
  void dispose() {
    // Avoid accessing ancestor widgets here
    super.dispose();
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
                  labelText: 'Playlist Name', hintText: 'Enter playlist name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Enter playlist description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                showSnackBar(context, 'Please enter a playlist name');
                return;
              }
              Navigator.pop(context); // Close dialog first
              final success =
                  await Provider.of<PlaylistsViewModel>(context, listen: false)
                      .createPlaylist(
                          nameController.text, descriptionController.text);

              if (success != null && mounted) { // Check if success is not null (playlist object)
                showSnackBar(context, 'Playlist \'${success.title}\' created successfully');
              } else if (mounted) {
                showSnackBar(context, 'Failed to create playlist. ${Provider.of<PlaylistsViewModel>(context, listen: false).errorMessage ?? ""}');
              }
            },
            child: const Text(
              'CREATE',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> removeSongFromPlaylist(String songId, String playlistId) async {
    try {
      // Debugging: Log the songId and playlistId
      print(
          'Attempting to remove song with ID: $songId from playlist with ID: $playlistId');

      final response =
          await Provider.of<PlaylistsViewModel>(context, listen: false)
              .removeSongFromPlaylist(songId, playlistId);

      // Debugging: Log the raw response
      print('Raw response from removeSongFromPlaylist: $response');

      if (response) {
        setState(() {
          // Refresh playlists after removing the song
          Provider.of<PlaylistsViewModel>(context, listen: false)
              .fetchPlaylists();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Song removed successfully')),
        );
      } else {
        throw Exception('Failed to remove song');
      }
    } catch (e) {
      // Debugging: Log the error
      print('Error while removing song: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove song: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,      appBar: AppBar(
        title: const Text('Playlists'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
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
          IconButton(
            icon: const Icon(Icons.add, size: Dimensions.iconSize), // Use Dimensions
            onPressed: _createPlaylist,
          ),
        ],
      ),
      body: Consumer<PlaylistsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showSnackBar(context, viewModel.errorMessage!);
              viewModel.clearError(); // Clear error after showing
            });
          }

          // Show loader only on initial fetch or if playlists are null/empty during load
          if (viewModel.isLoading && viewModel.playlists.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (viewModel.playlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No playlists yet',
                    style: AppTextStyles.body1,
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
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              itemCount: viewModel.playlists.length,
              itemBuilder: (context, index) {
                final playlist = viewModel.playlists[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: _buildPlaylistItem(context, playlist),
                );
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPlaylistItem(BuildContext context, Playlist playlist) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistDetailScreen(playlist: playlist),
          ),
        );
      },
      child: Row(
        children: [
          // Playlist thumbnail
          Container(
            width: 56.0,
            height: 56.0,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          const SizedBox(width: 16.0),
          // Playlist info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  playlist.title,
                  style: AppTextStyles.playlistTitle,
                ),
                const SizedBox(height: 4.0),
                Text(
                  '${playlist.songCount} Songs',
                  style: AppTextStyles.playlistSubtitle,
                ),
              ],
            ),
          ),
          // Replace the IconButton with PopupMenuButton
          PopupMenuButton<String>(
            icon: playlist.title == 'Anime Songs'
                ? const Icon(Icons.graphic_eq, size: Dimensions.iconSize)
                : const Icon(Icons.more_vert, size: Dimensions.iconSize),
            onSelected: (value) {
              if (value == 'edit') {
                _editPlaylist(playlist);
              } else if (value == 'delete') {
                _deletePlaylist(playlist.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: Dimensions.iconSize),
                    SizedBox(width: 8.0),
                    Text('Edit Playlist'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: Dimensions.iconSize),
                    SizedBox(width: 8.0),
                    Text('Delete Playlist'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editPlaylist(Playlist playlist) {
    final TextEditingController nameController =
        TextEditingController(text: playlist.title);
    final TextEditingController descriptionController =
        TextEditingController(text: playlist.description);

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
                  labelText: 'Playlist Name', hintText: 'Enter playlist name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Enter playlist description'),
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
              Navigator.pop(context); // Close dialog first
              final success =
                  await Provider.of<PlaylistsViewModel>(context, listen: false)
                      .updatePlaylist(playlist.id, nameController.text,
                          descriptionController.text);

              if (success && mounted) {
                showSnackBar(context, 'Playlist updated successfully');
              } else if (mounted) {
                showSnackBar(context, 'Failed to update playlist. ${Provider.of<PlaylistsViewModel>(context, listen: false).errorMessage ?? ""}');
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
              Navigator.pop(context); // Close dialog first
              final success =
                  await Provider.of<PlaylistsViewModel>(context, listen: false)
                      .deletePlaylist(playlistId);

              if (success && mounted) {
                showSnackBar(context, 'Playlist deleted successfully');
              } else if (mounted){
                showSnackBar(context, 'Failed to delete playlist. ${Provider.of<PlaylistsViewModel>(context, listen: false).errorMessage ?? ""}');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
