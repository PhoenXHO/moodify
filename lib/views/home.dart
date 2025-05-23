import 'package:emotion_music_player/views/search.dart';
import 'package:flutter/material.dart';
import 'package:emotion_music_player/theme/app_colors.dart';
import 'package:emotion_music_player/theme/dimensions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(initialQuery: ''),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        child: Center(child: Text("Home")),
      ),
    );
  }
}