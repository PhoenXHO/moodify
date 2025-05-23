import 'package:emotion_music_player/theme/dimensions.dart';
import 'package:emotion_music_player/viewmodels/player_viewmodel.dart';
import 'package:emotion_music_player/viewmodels/playlists_viewmodel.dart';
import 'package:emotion_music_player/viewmodels/favorites_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:emotion_music_player/models/song.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../widgets/snackbar.dart';

class SongWidget extends StatefulWidget {
  final Song song;
  final VoidCallback onFavoriteToggle;
  final bool inPlaylist;
  final Function? onRemove;
  final bool isFavoritesContext; // Added: Flag for favorites screen context

  const SongWidget({
    super.key,
    required this.song,
    required this.onFavoriteToggle,
    this.inPlaylist = false,
    this.onRemove,
    this.isFavoritesContext = false, // Added: Default to false
  });

  @override
  State<SongWidget> createState() => _SongWidgetState();
}

class _SongWidgetState extends State<SongWidget> {
  final supabase = Supabase.instance.client;
  late FavoritesViewModel _favoritesViewModel;
  bool _isFavorite = false;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.song.isFavorite;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _favoritesViewModel = Provider.of<FavoritesViewModel>(context, listen: false);
    _isFavorite = widget.song.isFavorite;
  }

  @override
  void didUpdateWidget(SongWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the song prop's favorite status has changed since the last build,
    // and our local _isFavorite state is not already reflecting this new status,
    // then update _isFavorite and call setState.
    if (oldWidget.song.isFavorite != widget.song.isFavorite) {
      if (_isFavorite != widget.song.isFavorite) {
        setState(() {
          _isFavorite = widget.song.isFavorite;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isTogglingFavorite) return; // Prevent multiple rapid taps
    
    try {
      _isTogglingFavorite = true;
      // Immediately update UI for better responsiveness
      setState(() {
        _isFavorite = !_isFavorite;
      });
      
      // Call the parent callback
      widget.onFavoriteToggle();
    } catch (e) {
      // Revert UI state if there's an error
      setState(() {
        _isFavorite = !_isFavorite;
      });
      if (mounted) {
        showSnackBar(context, 'Error toggling favorite: $e');
      }
    } finally {
      _isTogglingFavorite = false;
    }
  }
  
  // Check if song is in a specific playlist
  Future<bool> _isSongInPlaylist(String playlistId) async {
    final playlistsViewModel = Provider.of<PlaylistsViewModel>(context, listen: false);
    // First, force load the songs for this playlist if they're not loaded yet
    final songs = playlistsViewModel.getPlaylistSongs(playlistId);
    if (songs.isEmpty) {
      await playlistsViewModel.loadPlaylistSongs(playlistId);
    }
    
    // Now check if our song is in this playlist
    final updatedSongs = playlistsViewModel.getPlaylistSongs(playlistId);
    return updatedSongs.any((song) => song.id == widget.song.id);
  }
  
  @override
  Widget build(BuildContext context) {
    // Updated: Determine if the song should appear disabled
    final bool shouldAppearDisabled =
        widget.isFavoritesContext && !_isFavorite;
    final playerViewModel =
        Provider.of<PlayerViewModel>(context, listen: false);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      // Updated: Use AppColors.inactive if it should appear disabled
      color: shouldAppearDisabled ? AppColors.inactive : AppColors.cardBackground,
      child: ListTile(
        title: Text(
          widget.song.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            // Updated: Use AppColors.textSecondary if it should appear disabled
            color: shouldAppearDisabled
                ? AppColors.textSecondary
                : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          widget.song.artist,
          // Updated: Use AppColors.textSecondary if it should appear disabled for subtitle as well
          style: TextStyle(
            color: shouldAppearDisabled
                ? AppColors.textSecondary
                : AppColors.textSecondary, // Or keep default if preferred
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Always show the favorite button
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? AppColors.primary : null,
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

            // More options menu for adding to playlist (now shown both inside and outside playlists)
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
                  // Defer showing the bottom sheet until after the current build cycle
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _showPlaylistSelectionBottomSheet(context);
                    }
                  });
                }
              },
            ),
          ],
        ),
        onTap: () async {
          // Get the songs list and determine if we're in a playlist or favorites context
          if (widget.inPlaylist) {
            // This is a song in a playlist
            // Get the playlist ID and songs from the parent widget
            final playlistsViewModel = Provider.of<PlaylistsViewModel>(context, listen: false);
            final playlistId = playlistsViewModel.currentPlaylistId; // Assuming this is tracked in the ViewModel
            if (playlistId != null) {
              final playlistSongs = playlistsViewModel.getPlaylistSongs(playlistId);
              await playerViewModel.playSongFromPlaylist(widget.song, playlistSongs, playlistId);
            } else {
              // Fallback to regular play if playlist ID is not available
              await playerViewModel.playSong(widget.song);
            }
          } else if (widget.isFavoritesContext) {
            // This is a song in the favorites screen
            // Get all favorite songs from the parent
            final favoritesViewModel = Provider.of<FavoritesViewModel>(context, listen: false);
            final favoriteSongs = favoritesViewModel.favoriteSongs;
            await playerViewModel.playSongFromFavorites(widget.song, favoriteSongs);
          } else {
            // Regular song play (not from playlist or favorites)
            await playerViewModel.playSong(widget.song);
          }
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
            child: const Text(
                'CANCEL',
                style: TextStyle(color: AppColors.textSecondary),
            ),
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
                  playlist!.id,
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
            child: const Text(
              'CREATE',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // Show playlist selection bottom sheet
  void _showPlaylistSelectionBottomSheet(BuildContext context) {
    final playlistsViewModel = Provider.of<PlaylistsViewModel>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Add to Playlist',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  
                  Flexible(
                    child: FutureBuilder(
                      future: Future.microtask(() => playlistsViewModel.fetchPlaylists()), // Ensure fetchPlaylists is called after the current build phase
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting && playlistsViewModel.playlists.isEmpty) { // Show loader only if playlists are not yet loaded
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Error fetching playlists: ${snapshot.error}'));
                        }
                        
                        if (playlistsViewModel.playlists.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No playlists found',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          );
                        }
                        
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: playlistsViewModel.playlists.length,
                          itemBuilder: (context, index) {
                            final playlist = playlistsViewModel.playlists[index];
                            // Check if the current song already exists in this playlist
                            final songsInThisPlaylist = playlistsViewModel.getPlaylistSongs(playlist.id);
                            final songExistsInPlaylist = songsInThisPlaylist.any((s) => s.id == widget.song.id);

                            return ListTile(
                              title: Text(
                                playlist.title, // Display playlist title
                                style: TextStyle(
                                  color: songExistsInPlaylist 
                                    ? AppColors.textSecondary.withOpacity(0.4) // More opacity reduction
                                    : AppColors.textPrimary,
                                  fontStyle: songExistsInPlaylist 
                                    ? FontStyle.italic // Make text italic for existing items
                                    : FontStyle.normal,
                                ),
                              ),
                              subtitle: playlist.description != null && playlist.description!.isNotEmpty
                                  ? Text(
                                      playlist.description!,
                                      style: TextStyle(
                                        color: songExistsInPlaylist 
                                          ? AppColors.textSecondary.withOpacity(0.4) // More opacity reduction
                                          : AppColors.textSecondary,
                                        fontStyle: songExistsInPlaylist 
                                          ? FontStyle.italic // Make text italic for existing items
                                          : FontStyle.normal,
                                      ),
                                    )
                                  : null,
                              // Add trailing icon to indicate song is already in playlist
                              trailing: songExistsInPlaylist 
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ) 
                                : null,
                              // Apply tileColor to visually separate disabled items
                              tileColor: songExistsInPlaylist 
                                ? AppColors.inactive.withOpacity(0.3)
                                : null,
                              enabled: !songExistsInPlaylist, // Disable if song already in playlist
                              onTap: songExistsInPlaylist
                                ? null // Do nothing if song is already in the playlist
                                : () async {
                                    Navigator.pop(context); // Close bottom sheet first
                                    try {
                                      await playlistsViewModel.addSongToPlaylist(
                                        playlist.id,
                                        widget.song.id,
                                      );
                                      // Use current context for snackbar
                                      showSnackBar(
                                        this.context, // Use SongWidget's context
                                        '"${widget.song.title}" added to "${playlist.title}"',
                                      );
                                    } catch (e) {
                                      // Use current context for snackbar
                                      showSnackBar(
                                        this.context, // Use SongWidget's context
                                        'Error adding song: $e',
                                      );
                                    }
                                  },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  
                  // Create new playlist button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close bottom sheet
                        _showCreatePlaylistDialog(context); // Show create dialog
                      },
                      child: const Text('Create New Playlist'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
