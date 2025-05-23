import 'package:emotion_music_player/services/audioplayer_service.dart';
import 'package:emotion_music_player/viewmodels/player_viewmodel.dart';
import 'package:emotion_music_player/theme/app_colors.dart';
import 'package:emotion_music_player/theme/text_styles.dart';
import 'package:emotion_music_player/theme/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class MiniPlayer extends StatefulWidget {
  final bool isMinimized;

  const MiniPlayer({
    super.key,
    this.isMinimized = false,
  });

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  PlayerViewModel? _playerViewModel; // Store the ViewModel instance

  @override
  void initState() {
    super.initState();
    // Schedule a post-frame callback to register for song changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the widget is still mounted before accessing context
      if (mounted) {
        _playerViewModel = Provider.of<PlayerViewModel>(context, listen: false);
        _playerViewModel?.addListener(_handlePlayerChanges);
      }
    });
  }

  void _handlePlayerChanges() {
    // Force a rebuild when the player state changes
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    // Use the stored _playerViewModel instance
    _playerViewModel?.removeListener(_handlePlayerChanges);
    super.dispose();
  }

  void _closePlayer() {
    // Use the stored _playerViewModel instance
    // Ensure _playerViewModel is not null before using it
    if (_playerViewModel == null) return;

    // Stop playback first
    _playerViewModel!.togglePlayPause();
    
    // Create a small delay to ensure the player state updates before closing
    Future.delayed(const Duration(milliseconds: 100), () {
      // Use a complete approach to reset the player state
      // Check if mounted again before calling, as the delay might outlive the widget
      if (mounted && _playerViewModel != null) {
        _playerViewModel!.closePlayer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PlayerViewModel>(context);
    final currentSong = viewModel.currentSong;

    if (currentSong == null) return const SizedBox.shrink(); // Add this check

    // Calculate safe area to avoid overlapping with system UI
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Return the minimized version for the chat screen
    if (widget.isMinimized) {
      return _buildMinimizedPlayer(viewModel, currentSong, bottomPadding);
    }
    
    // Return the regular mini player for all other screens
    return _buildFullPlayer(viewModel, currentSong, bottomPadding);
  }

  Widget _buildMinimizedPlayer(PlayerViewModel viewModel, currentSong, double bottomPadding) {
    return Container(
      height: Dimensions.miniPlayerMinimizedHeight,
      margin: EdgeInsets.only(
        left: 16.0, 
        right: 16.0,
        bottom: bottomPadding + 16.0
      ),
      decoration: BoxDecoration(
        color: AppColors.miniPlayerBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: ClipRRect( // Added ClipRRect to clip the progress bar
        borderRadius: BorderRadius.circular(16.0), // Match the container's border radius
        child: Column(
          children: [
            // Main content
            Expanded(
              child: Row(
                children: [
                  // Album art (if available)
                  const SizedBox(width: 16.0),
                  
                  // Song info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Song title
                        Text(
                          currentSong.title,
                          style: AppTextStyles.songTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Artist name
                        Text(
                          currentSong.artist,
                          style: AppTextStyles.artistName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Playback controls
                  StreamBuilder<PlayerState>(
                    stream: viewModel.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final isPlaying = playerState?.playing ?? false;
                      
                      return IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          size: Dimensions.iconSizeLarge,
                        ),
                        color: AppColors.primary,
                        onPressed: viewModel.togglePlayPause,
                      );
                    }
                  ),
                  
                  // Close button
                  IconButton(
                    icon: Icon(Icons.close, size: Dimensions.iconSizeSmall),
                    color: AppColors.textSecondary,
                    onPressed: _closePlayer,
                  ),
                  
                  const SizedBox(width: 8.0),
                ],
              ),
            ),
            
            // Non-interactive progress bar for minimized player
            StreamBuilder<PositionData>(
              stream: viewModel.positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                final position = positionData?.position ?? Duration.zero;
                final duration = positionData?.duration ?? Duration.zero;
                
                double value = 0.0;
                if (duration.inMilliseconds > 0) {
                  value = position.inMilliseconds / duration.inMilliseconds;
                  // Ensure value is always between 0.0 and 1.0
                  value = value.clamp(0.0, 1.0);
                }
                
                return Container(
                  height: 4.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.progressBackground,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16.0),
                          bottomRight: Radius.circular(16.0),
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
          ],
        ),
      ), // Closing parenthesis for ClipRRect
    );
  }
  
  Widget _buildFullPlayer(PlayerViewModel viewModel, currentSong, double bottomPadding) {
    return Container(
      margin: EdgeInsets.only(
        left: 16.0, 
        right: 16.0,
        bottom: bottomPadding + 16.0
      ),
      decoration: BoxDecoration(
        color: AppColors.miniPlayerBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button and song info row
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 12.0),
            child: Row(
              children: [
                // Song info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Song title
                      Text(
                        currentSong.title,
                        style: AppTextStyles.songTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Artist name
                      Text(
                        currentSong.artist,
                        style: AppTextStyles.artistName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Close button
                IconButton(
                  icon: Icon(Icons.close, size: Dimensions.iconSizeSmall),
                  color: AppColors.textSecondary,
                  onPressed: _closePlayer,
                ),
              ],
            ),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StreamBuilder<PositionData>(
              stream: viewModel.positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                final position = positionData?.position ?? Duration.zero;
                final duration = positionData?.duration ?? Duration.zero;
                
                double value = 0.0;
                if (duration.inMilliseconds > 0) {
                  value = position.inMilliseconds / duration.inMilliseconds;
                  // Ensure value is always between 0.0 and 1.0
                  value = value.clamp(0.0, 1.0);
                }

                return SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.progressBackground,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: value,
                    onChanged: (value) {
                      final newPosition = Duration(
                        milliseconds: (value * duration.inMilliseconds).round(),
                      );
                      viewModel.seekTo(newPosition);
                    },
                  ),
                );
              }
            ),
          ),

          // Playback controls
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Shuffle button
                IconButton(
                  icon: Icon(
                    Icons.shuffle,
                    size: Dimensions.iconSize,
                    color: viewModel.isShuffleEnabled
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  onPressed: viewModel.isPlayingFromPlaylistOrFavorites
                      ? viewModel.toggleShuffle
                      : null,
                ),                // Previous button
                IconButton(
                  icon: Icon(
                    Icons.skip_previous,
                    size: Dimensions.iconSizeMedium,
                    color: viewModel.isPlayingFromPlaylistOrFavorites
                        ? (viewModel.hasPrevious 
                            ? AppColors.textPrimary 
                            : AppColors.inactive.withOpacity(0.7))
                        : AppColors.inactive,
                  ),
                  onPressed: viewModel.isPlayingFromPlaylistOrFavorites
                      ? viewModel.playPrevious
                      : null,
                ),

                // Play/Pause button
                StreamBuilder<PlayerState>(
                  stream: viewModel.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final isPlaying = playerState?.playing ?? false;

                    return IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        size: Dimensions.iconSizeLarge,
                      ),
                      color: AppColors.primary,
                      onPressed: viewModel.togglePlayPause,
                    );
                  }
                ),                // Next button
                IconButton(
                  icon: Icon(
                    Icons.skip_next,
                    size: Dimensions.iconSizeMedium,
                    color: viewModel.isPlayingFromPlaylistOrFavorites
                        ? (viewModel.hasNext 
                            ? AppColors.textPrimary 
                            : AppColors.inactive.withOpacity(0.7))
                        : AppColors.inactive,
                  ),
                  onPressed: viewModel.isPlayingFromPlaylistOrFavorites
                      ? viewModel.playNext
                      : null,
                ),

                // Repeat button
                IconButton(
                  icon: Icon(
                    Icons.repeat,
                    size: Dimensions.iconSize,
                    color: viewModel.isLoopEnabled
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  onPressed: viewModel.isPlayingFromPlaylistOrFavorites
                      ? viewModel.toggleLoop
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}