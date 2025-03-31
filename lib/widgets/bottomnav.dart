import 'package:flutter/material.dart';
import 'package:emotion_music_player/views/home.dart';
import 'package:emotion_music_player/views/playlists.dart';
import 'package:emotion_music_player/views/chat.dart';
import 'package:emotion_music_player/views/favorites.dart';
import 'package:emotion_music_player/views/settings.dart';
import 'package:provider/provider.dart';

import '../viewmodels/favorites_viewmodel.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;
  late List<Widget> screens;

  @override
  void initState() {
    screens = [
      HomeScreen(),
      PlaylistsScreen(),
      ChatScreen(),
      FavoritesScreen(),
      SettingsScreen()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      bottomNavigationBar: Container(
        width: 320, 
        height: 51, 
        margin: EdgeInsets.only(bottom: 10), 
        decoration: BoxDecoration(
          color: Colors.black,
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
      body: screens[currentTabIndex],
    );
  }

  Widget _navItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        if (currentTabIndex == 3 && index != 3) {
          // Clean up unfavorited songs when navigating away from the Favorites screen
          Provider.of<FavoritesViewModel>(context, listen: false).cleanupUnfavoritedSongs();
        }
        setState(() {
          currentTabIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24), 
          if (currentTabIndex == index)
            Container(
              width: 6,
              height: 6,
              margin: EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
