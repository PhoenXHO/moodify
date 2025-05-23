import 'package:flutter/material.dart';
import 'package:emotion_music_player/models/song.dart';
import 'package:emotion_music_player/widgets/song_widget.dart';

class SongListWidget extends StatelessWidget {
  final List<Song> songs;
  final bool isLoading;
  final Function(Song) onFavoriteToggle;
  final bool allowReordering;
  final Function(int, int)? onReorder;
  final Function(String)? onRemove;
  final bool isFavoritesContext; // Added: Flag for favorites screen context

  const SongListWidget({
    super.key,
    required this.songs,
    required this.isLoading,
    required this.onFavoriteToggle,
    this.allowReordering = false,
    this.onReorder,
    this.onRemove,
    this.isFavoritesContext = false, // Added: Default to false
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (songs.isEmpty) {
      return const Center(child: Text('No songs found'));
    }

    // If reordering is allowed, use ReorderableListView
    if (allowReordering && onReorder != null) {
      return ReorderableListView.builder(
        itemCount: songs.length,
        onReorder: onReorder!,
        itemBuilder: (context, index) {
          final song = songs[index];
          return SongWidget(
            key: ValueKey(song.id), // Required for reordering
            song: song,
            onFavoriteToggle: () => onFavoriteToggle(song),
            inPlaylist: true,
            onRemove: onRemove != null ? () => onRemove!(song.id) : null,
            isFavoritesContext: isFavoritesContext, // Added: Pass down the flag
          );
        },
      );
    }

    // Otherwise use regular ListView
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return SongWidget(
          song: song,
          onFavoriteToggle: () => onFavoriteToggle(song),
          inPlaylist: false, // This was false, assuming it's correct for non-reorderable lists
          isFavoritesContext: isFavoritesContext, // Added: Pass down the flag
        );
      },
    );
  }
}
