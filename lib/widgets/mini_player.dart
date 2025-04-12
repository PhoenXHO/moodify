import 'package:emotion_music_player/services/audioplayer_service.dart';
import 'package:emotion_music_player/viewmodels/player_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  @override
  void initState() {
    super.initState();
    // Schedule a post-frame callback to register for song changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playerViewModel = Provider.of<PlayerViewModel>(context, listen: false);
      playerViewModel.addListener(_handlePlayerChanges);
    });
  }

  void _handlePlayerChanges() {
    // Force a rebuild when the player state changes
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    Provider.of<PlayerViewModel>(context, listen: false).removeListener(_handlePlayerChanges);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PlayerViewModel>(context);
    final currentSong = viewModel.currentSong;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ]
      ),
      child: Column(
        children: [
          // Progress bar
          StreamBuilder<PositionData>(
            stream: viewModel.positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              final position = positionData?.position ?? Duration.zero;
              final duration = positionData?.duration ?? Duration.zero;

              return LinearProgressIndicator(
                value: duration.inMilliseconds > 0 ?
                    position.inMilliseconds / duration.inMilliseconds
                    : 0.0,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: 2,
              );
            }
          ),

          // Song info and controls
          Expanded(
            child: Row(
              children: [
                // Album art
                // AspectRatio(
                //   aspectRatio: 1,
                //   child: Container(
                //     margin: const EdgeInsets.all(4),
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(4),
                //       image: const DecorationImage(
                //         image: AssetImage('assets/album_art.png'),
                //         fit: BoxFit.cover,
                //       ),
                //     ),
                //   ),
                // )

                // Song info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Song title
                        Text(currentSong!.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Artist name
                        Text(currentSong.artist,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // Playback controls
                StreamBuilder<PlayerState>(
                  stream: viewModel.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final isPlaying = playerState?.playing ?? false;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Previous button
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          onPressed: null, // TODO: Implement previous song action for playlists
                        ),

                        // Play/Pause button
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 32,
                          ),
                          onPressed: viewModel.togglePlayPause,
                        ),

                        // Next button
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          onPressed: null, // TODO: Implement next song action for playlists
                        ),
                      ],
                    );
                  }
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}