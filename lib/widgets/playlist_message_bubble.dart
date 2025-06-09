import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/playlist.dart';
import '../theme/app_colors.dart';
import '../viewmodels/playlists_viewmodel.dart';
import '../views/playlist_contents.dart';

class PlaylistMessageBubble extends StatelessWidget {
  final String message;
  final String playlistName;
  final String? playlistId;

  const PlaylistMessageBubble({
    super.key,
    required this.message,
    required this.playlistName,
    this.playlistId,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.music_note, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Playlist card embedded within message bubble
                  InkWell(
                    onTap: () => _navigateToPlaylist(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.surfaceLight.withOpacity(0.9),
                            AppColors.cardBackground.withOpacity(0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.playlist_add_check,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              playlistName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                  // Message text below the playlist card
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPlaylist(BuildContext context) {
    if (playlistId == null) {
      // Show error if playlist ID is missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot find this playlist'),
          backgroundColor: AppColors.buttonDanger,
        ),
      );
      return;
    }

    // Find the playlist in the viewmodel
    final playlistsViewModel = Provider.of<PlaylistsViewModel>(context, listen: false);
    playlistsViewModel.fetchPlaylists().then((_) {
      final playlists = playlistsViewModel.playlists;
      final playlist = playlists.firstWhere(
        (p) => p.id == playlistId,
        orElse: () => Playlist(
          id: playlistId!,
          title: playlistName,
          songCount: 0,
          userId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Navigate to the playlist details screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaylistDetailScreen(playlist: playlist),
        ),
      );
    }).catchError((error) {
      // Show error if navigation fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load playlist: $error'),
          backgroundColor: AppColors.buttonDanger,
        ),
      );
    });
  }
}
