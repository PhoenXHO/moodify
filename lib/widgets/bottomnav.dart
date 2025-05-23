import 'package:flutter/material.dart';
import 'package:emotion_music_player/views/home.dart';
import 'package:emotion_music_player/views/playlists.dart';
import 'package:emotion_music_player/views/chat.dart';
import 'package:emotion_music_player/views/favorites.dart' as favorites_view;
import 'package:emotion_music_player/views/settings.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../theme/dimensions.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../viewmodels/player_viewmodel.dart';
import '../viewmodels/navigation_viewmodel.dart';
import 'mini_player.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {@override
  Widget build(BuildContext context) {
    // Listen to player changes explicitly
    final playerViewModel = Provider.of<PlayerViewModel>(context);
    final navigationViewModel = Provider.of<NavigationViewModel>(context);
    
    final currentTabIndex = navigationViewModel.currentTabIndex;
    final isChatScreen = currentTabIndex == 2;

    // Create screens dynamically to handle chat initial prompt
    final List<Widget> dynamicScreens = [
      HomeScreen(),
      PlaylistsScreen(),
      ChatScreen(initialPrompt: navigationViewModel.chatInitialPrompt),
      favorites_view.FavoritesScreen(),
      SettingsScreen()
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Main content area
          dynamicScreens[currentTabIndex],

          // Mini player - positioned above bottom nav
          if (playerViewModel.currentSong != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: isChatScreen ? Dimensions.bottomNavHeight + 18.0 : 18.0, // Increased bottom value
              child: MiniPlayer(isMinimized: isChatScreen), // Pass isMinimized
            ),
        ],
      ),
      backgroundColor: AppColors.background,
      bottomNavigationBar: Container(
        width: 320, 
        height: Dimensions.bottomNavHeight, // Use Dimensions
        margin: const EdgeInsets.only(bottom: 32, left: 8, right: 8), // Increased bottom margin for better separation
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, 0),
            _navItem(Icons.grid_view_rounded, 1),
            _navItem(Icons.chat_bubble_outline, 2),
            _navItem(Icons.star_border, 3),
            _navItem(Icons.tune, 4),
          ],
        ),
      ),
    );
  }
  Widget _navItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        final navigationViewModel = Provider.of<NavigationViewModel>(context, listen: false);
        final currentTabIndex = navigationViewModel.currentTabIndex;
        
        if (currentTabIndex == 3 && index != 3) {
          // Clean up unfavorited songs when navigating away from the Favorites screen
          Provider.of<FavoritesViewModel>(context, listen: false).cleanupUnfavoritedSongs();
        }
        
        navigationViewModel.setTabIndex(index);
      },
      child: Consumer<NavigationViewModel>(
        builder: (context, navigationViewModel, child) {
          final currentTabIndex = navigationViewModel.currentTabIndex;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: Dimensions.iconSize), // Use Dimensions for icon size
              if (currentTabIndex == index)
                Container(
                  width: 6,
                  height: 6,
                  margin: EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
