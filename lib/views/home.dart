import 'package:emotion_music_player/models/song.dart';
import 'package:emotion_music_player/models/playlist.dart';
import 'package:emotion_music_player/repositories/song_repository.dart';
import 'package:emotion_music_player/repositories/playlist_repository.dart';
import 'package:emotion_music_player/repositories/auth_repository.dart';
import 'package:emotion_music_player/viewmodels/player_viewmodel.dart';
import 'package:emotion_music_player/viewmodels/navigation_viewmodel.dart';
import 'package:emotion_music_player/viewmodels/favorites_viewmodel.dart';
import 'package:emotion_music_player/views/search.dart';
import 'package:emotion_music_player/views/playlist_contents.dart';
import 'package:emotion_music_player/widgets/song_widget.dart';
import 'package:flutter/material.dart';
import 'package:emotion_music_player/theme/app_colors.dart';
import 'package:emotion_music_player/theme/dimensions.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final SongRepository _songRepository = SongRepository();
  final PlaylistRepository _playlistRepository = PlaylistRepository();
  final AuthRepository _authRepository = AuthRepository();
  
  List<Song> _recentSongs = [];
  List<Playlist> _userPlaylists = [];
  bool _isLoading = true;
  String? _errorMessage;
  late FavoritesViewModel _favoritesViewModel;
  
  // Available genres with corresponding colors and icons
  final List<Map<String, dynamic>> _genres = [
    {
      'name': 'Pop',
      'color': const Color(0xFFE57373),
      'icon': Icons.music_note,
    },
    {
      'name': 'Rock',
      'color': const Color(0xFF64B5F6),
      'icon': Icons.celebration, // Using a more appropriate icon
    },
    {
      'name': 'Hip Hop',
      'color': const Color(0xFFFFB74D),
      'icon': Icons.headphones,
    },
    {
      'name': 'Classical',
      'color': const Color(0xFF81C784),
      'icon': Icons.piano, 
    },
    {
      'name': 'Jazz',
      'color': const Color(0xFFBA68C8),
      'icon': Icons.music_note,
    },
    {
      'name': 'Electronic',
      'color': const Color(0xFF4DD0E1),
      'icon': Icons.electrical_services,
    }
  ];
  
  // Mood collections with predefined emojis
  final List<Map<String, dynamic>> _moods = [
    {'name': 'Happy', 'emoji': '😊'},
    {'name': 'Energetic', 'emoji': '⚡'},
    {'name': 'Calm', 'emoji': '😌'},
    {'name': 'Sad', 'emoji': '😢'},
    {'name': 'Romantic', 'emoji': '❤️'},
    {'name': 'Focus', 'emoji': '🧠'},
  ];

  @override
  bool get wantKeepAlive => true;
    @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _favoritesViewModel = Provider.of<FavoritesViewModel>(context, listen: false);
    // Listen for changes to favorites
    _favoritesViewModel.addListener(_updateFavoritesStatus);
  }
  
  @override
  void dispose() {
    _favoritesViewModel.removeListener(_updateFavoritesStatus);
    super.dispose();
  }
  
  void _updateFavoritesStatus() {
    if (_recentSongs.isEmpty) return;
    
    final favoriteIds = _favoritesViewModel.favoriteSongs
        .map((song) => song.id)
        .toSet();
    
    bool needsUpdate = false;
    
    for (var song in _recentSongs) {
      final isFavorite = favoriteIds.contains(song.id);
      if (song.isFavorite != isFavorite) {
        song.isFavorite = isFavorite;
        needsUpdate = true;
      }
    }
    
    if (needsUpdate && mounted) {
      setState(() {});
    }
  }
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final user = _authRepository.getCurrentUser();
      if (user != null) {
        // Load recent songs (using top songs by favorite count as a placeholder)
        final songs = await _songRepository.getAllSongs();
        // Sort by favorite count to get most popular songs
        songs.sort((a, b) => b.favoriteCount.compareTo(a.favoriteCount));
        // Take only the first 10 songs
        _recentSongs = songs.take(10).toList();
        
        // Load user playlists
        _userPlaylists = await _playlistRepository.getUserPlaylists(user.id);
        
        // Fetch favorites to mark songs correctly
        await _favoritesViewModel.fetchFavorites();
        final favoriteIds = _favoritesViewModel.favoriteSongs
            .map((song) => song.id)
            .toSet();
            
        // Update favorite status for each song
        for (var song in _recentSongs) {
          song.isFavorite = favoriteIds.contains(song.id);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading home data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  void _navigateToSearch(String initialQuery) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(initialQuery: initialQuery),
      ),
    );
  }  void _navigateToMoodChat(String mood) {
    // Format the message to be more conversational
    String prompt = "";
    switch(mood.toLowerCase()) {
      case "happy":
        prompt = "Create a playlist with upbeat and happy songs";
        break;
      case "energetic":
        prompt = "Create an energetic playlist to boost my workout";
        break;
      case "calm":
        prompt = "I need a playlist with calm and relaxing songs";
        break;
      case "sad":
        prompt = "Make me a playlist with emotional and melancholic songs";
        break;
      case "romantic":
        prompt = "Create a romantic playlist for a special evening";
        break;
      case "focus":
        prompt = "I need a playlist to help me focus and concentrate on work";
        break;
      default:
        prompt = "Create a playlist for $mood mood";
    }
    
    // Use NavigationViewModel to navigate to chat with prompt instead of Navigator.push
    final navigationViewModel = Provider.of<NavigationViewModel>(context, listen: false);
    navigationViewModel.navigateToChatWithPrompt(prompt);
  }void _openPlaylist(Playlist playlist) {
    // Debug log to check playlist data
    print('Opening playlist: ${playlist.id}, ${playlist.title}, Songs count: ${playlist.songs.length}');
    
    // Navigate to playlist contents screen using MaterialPageRoute
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailScreen(playlist: playlist),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Moodify'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: false, // Remove back button
        actions: [
          // Add search button to AppBar
          IconButton(
            icon: const Icon(Icons.search, size: Dimensions.iconSize),
            onPressed: () => _navigateToSearch(''),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          )
        : _errorMessage != null 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.m,
                        vertical: Dimensions.s,
                      ),
                      child: Text(
                        'Welcome to Moodify',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    
                    // Description text
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.m,
                        vertical: Dimensions.xs,
                      ),
                      child: Text(
                        'Discover music based on your mood',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: Dimensions.m),
                    
                    // Mood Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.m,
                        vertical: Dimensions.s,
                      ),
                      child: Text(
                        'How are you feeling today?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    
                    // Mood cards horizontal scrolling
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.s),
                        scrollDirection: Axis.horizontal,
                        itemCount: _moods.length,
                        itemBuilder: (context, index) {
                          final mood = _moods[index];                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () => _navigateToMoodChat(mood['name']),
                              child: Container(
                                width: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(Dimensions.borderRadiusMedium),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      mood['emoji'],
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(height: Dimensions.xs),
                                    Text(
                                      mood['name'],
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: Dimensions.m),
                    
                    // Genre Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.m,
                        vertical: Dimensions.s,
                      ),
                      child: Text(
                        'Browse by Genre',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    
                    // Genre grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.m),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.0,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _genres.length,
                      itemBuilder: (context, index) {
                        final genre = _genres[index];
                        return InkWell(
                          onTap: () => _navigateToSearch(genre['name']),
                          child: Container(
                            decoration: BoxDecoration(
                              color: genre['color'].withOpacity(0.8),
                              borderRadius: BorderRadius.circular(Dimensions.borderRadiusMedium),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -10,
                                  bottom: -10,
                                  child: Icon(
                                    genre['icon'],
                                    size: 80,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(Dimensions.m),
                                  child: Text(
                                    genre['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: Dimensions.m),
                    
                    // Recent Playlists Section (if user has playlists)
                    if (_userPlaylists.isNotEmpty) ... [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.m,
                          vertical: Dimensions.s,
                        ),
                        child: Text(
                          'Your Playlists',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),                      
                      // Playlists horizontal list
                      SizedBox(
                        height: 170, // Increased height to fix overflow
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.s),
                          scrollDirection: Axis.horizontal,
                          itemCount: _userPlaylists.length,
                          itemBuilder: (context, index) {
                            final playlist = _userPlaylists[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () => _openPlaylist(playlist),
                                child: Container(
                                  width: 160,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(Dimensions.borderRadiusMedium),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [                                      Container(
                                        height: 95, // Slightly reduced height
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.3),
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(Dimensions.borderRadiusMedium),
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.music_note,
                                            color: Colors.white.withOpacity(0.8),
                                            size: 40,
                                          ),
                                        ),
                                      ),                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Reduced vertical padding
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min, // Use minimum space needed
                                          children: [
                                            Text(
                                              playlist.title,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2), // Small space between title and count
                                            Text(
                                              '${playlist.songCount} songs',
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: Dimensions.m),
                    ],
                    
                    // Popular Songs Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.m,
                        vertical: Dimensions.s,
                      ),
                      child: Text(
                        'Top Songs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    
                    // Recent Songs List
                    _recentSongs.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.l),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.music_off,
                                  color: AppColors.textSecondary,
                                  size: 48,
                                ),
                                const SizedBox(height: Dimensions.s),
                                Text(
                                  'No songs available',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _recentSongs.length,
                          itemBuilder: (context, index) {
                            final song = _recentSongs[index];
                            return Consumer<PlayerViewModel>(
                              builder: (context, playerViewModel, child) {
                                return SongWidget(
                                  song: song,
                                  onFavoriteToggle: () async {
                                    final result = await _songRepository.toggleFavorite(
                                      _authRepository.getCurrentUser()?.id ?? '',
                                      song.id,
                                    );
                                    if (result) {
                                      setState(() {
                                        song.isFavorite = !song.isFavorite;
                                      });
                                    }
                                  },
                                );
                              },
                            );
                          },
                        ),
                        
                    // Bottom spacing for mini player
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }
}