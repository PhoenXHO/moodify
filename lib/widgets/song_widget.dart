import 'package:emotion_music_player/theme/dimensions.dart';
import 'package:emotion_music_player/viewmodels/player_viewmodel.dart';
import 'package:emotion_music_player/viewmodels/playlists_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:emotion_music_player/models/song.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../widgets/snackbar.dart';

class SongWidget extends StatefulWidget {
  final Song song;
  final VoidCallback onFavoriteToggle; // Change to VoidCallback (no parameters)
  final bool inPlaylist;
  final Function? onRemove;

  const SongWidget({
    super.key,
    required this.song,
    required this.onFavoriteToggle,
    this.inPlaylist = false,
    this.onRemove,
  });

  @override
  State<SongWidget> createState() => _SongWidgetState();
}

class _SongWidgetState extends State<SongWidget> {
  final supabase = Supabase.instance.client;

  Future<void> _toggleFavorite() async {
    try {
      widget.onFavoriteToggle(); // Call without parameters
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error toggling favorite: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnfavorited = !widget.song.isFavorite;
    final playerViewModel =
        Provider.of<PlayerViewModel>(context, listen: false);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: isUnfavorited ? Colors.grey[200] : null,
      child: ListTile(
        title: Text(
          widget.song.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnfavorited ? Colors.grey : null,
          ),
        ),
        subtitle: Text(widget.song.artist),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Always show the favorite button
            IconButton(
              icon: Icon(
                widget.song.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: widget.song.isFavorite ? AppColors.primary : null,
              ),
              onPressed: _toggleFavorite,
            ),
            // Show remove button only if in playlist AND onRemove is provided
            if (widget.inPlaylist && widget.onRemove != null)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: Dimensions.iconSizeSmall), // Use Dimensions
                onPressed: () {
                  widget.onRemove?.call(); // Ensure the callback is invoked
                },
              ),

            // More options menu for adding to playlist
            if (!widget.inPlaylist)
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'add_to_playlist',
                    child: const Text('Add to playlist'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'add_to_playlist') {
                    _showCreatePlaylistDialog(context);
                    // here we must add the functionality to add to existing playlists
                  }
                },
              ),
          ],
        ),
        onTap: () async {
          await playerViewModel.playSong(widget.song);
        },
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Playlist'),
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
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                showSnackBar(context, 'Please enter a playlist name');
                return;
              }

              final playlistsViewModel =
                  Provider.of<PlaylistsViewModel>(context, listen: false);
              try {
                final playlist = await playlistsViewModel.createPlaylist(
                  nameController.text,
                  descriptionController.text,
                );

                // Add the current song to the new playlist
                await playlistsViewModel.addSongToPlaylist(
                  playlist.id,
                  widget.song.id,
                );

                if (context.mounted) {
                  Navigator.of(context).pop();
                  showSnackBar(
                    context,
                    'Created playlist and added "${widget.song.title}"',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  showSnackBar(context, 'Error creating playlist: $e');
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
