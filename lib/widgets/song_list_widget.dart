import 'package:flutter/material.dart';
import 'package:emotion_music_player/models/song.dart';
import 'package:emotion_music_player/widgets/song_widget.dart';

class SongListWidget extends StatelessWidget {
  final List<Song> songs;
  final bool isLoading;
  final Function(Song) onFavoriteToggle; // Keep this as Function(Song) to match how we use it
  final bool allowReordering;
  final Function(int, int)? onReorder;
  final Function(String)? onRemove;

  const SongListWidget({
    super.key,
    required this.songs,
    required this.isLoading,
    required this.onFavoriteToggle,
    this.allowReordering = false,
    this.onReorder,
    this.onRemove,
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
            onFavoriteToggle: () => onFavoriteToggle(song), // Make sure we pass the entire song
            inPlaylist: true,
            onRemove: onRemove != null ? () => onRemove!(song.id) : null,
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
          onFavoriteToggle: () => onFavoriteToggle(song), // Wrap in a VoidCallback
          inPlaylist: false,
        );
      },
    );
  }
}
