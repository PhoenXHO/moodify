import 'package:flutter/material.dart';
import 'package:emotion_music_player/pages/Home.dart';
import 'package:emotion_music_player/pages/Playlist.dart';
import 'package:emotion_music_player/pages/chat.dart';
import 'package:emotion_music_player/pages/fav.dart';
import 'package:emotion_music_player/pages/settings.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;

  late List<Widget> pages;
  late Home homepages;
  late Chat chat;
  late Fav fav;
  late Settings settings;
  late Playlist playlist;

  @override
  void initState() {
    homepages = Home();
    chat = Chat();
    fav = Fav();
    settings = Settings();
    playlist = Playlist();

    pages = [homepages, playlist, chat, fav, settings];
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
      body: pages[currentTabIndex],
    );
  }

  Widget _navItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
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
