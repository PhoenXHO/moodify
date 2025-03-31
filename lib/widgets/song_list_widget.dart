import 'package:flutter/material.dart';
import 'package:emotion_music_player/models/song.dart';
import 'package:emotion_music_player/widgets/song_widget.dart';

class SongListWidget extends StatelessWidget {
  final List<Song> songs;
  final bool isLoading;
  final Function onFavoriteToggle;

  const SongListWidget({
    Key? key,
    required this.songs,
    required this.isLoading,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (songs.isEmpty) {
      return const Center(child: Text('No songs found'));
    }

    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return SongWidget(
          song: song,
          onFavoriteToggle: onFavoriteToggle,
        );
      },
    );
  }
}
