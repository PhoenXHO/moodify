import 'package:flutter/material.dart';
import '../models/song.dart';
import '../repositories/song_repository.dart';

class SongSelectionScreen extends StatefulWidget {
  const SongSelectionScreen({Key? key}) : super(key: key);

  @override
  _SongSelectionScreenState createState() => _SongSelectionScreenState();
}

class _SongSelectionScreenState extends State<SongSelectionScreen> {
  // Simplified state management
  final SongRepository _songRepository = SongRepository();
  List<Song> _songs = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Load songs directly in initState
    _loadSongs();
  }

  // Simple load method that runs once and doesn't use complex state management
  void _loadSongs() {
    print("🚀 SongSelectionScreen: Starting to load songs");

    // Explicitly set loading state
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Use a direct approach without awaiting
    _songRepository.getAllSongs().then((songs) {
      print("✅ SongSelectionScreen: Loaded ${songs.length} songs, updating UI");

      // Only update if widget is still mounted
      if (mounted) {
        setState(() {
          _songs = songs;
          _isLoading = false;
        });
      }
    }).catchError((error) {
      print("❌ SongSelectionScreen: Error loading songs: $error");

      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load songs: $error";
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Debug print to track rebuilds
    print(
        "🔄 SongSelectionScreen: Building UI (loading: $_isLoading, songs: ${_songs.length})");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Songs'),
        actions: [
          // Add an action to manually print state for debugging
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () {
              print(
                  "🔍 Debug - Loading: $_isLoading, Songs: ${_songs.length}, Error: $_errorMessage");
            },
          ),
        ],
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadSongs,
        child: const Icon(Icons.refresh),
        tooltip: 'Reload Songs',
      ),
    );
  }

  Widget _buildContent() {
    // Loading state
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading songs...'),
          ],
        ),
      );
    }

    // Error state
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(_errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSongs,
              child: Text('Try Again'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (_songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, color: Colors.grey, size: 48),
            SizedBox(height: 16),
            Text('No songs available'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSongs,
              child: Text('Refresh'),
            ),
          ],
        ),
      );
    }

    // Songs list
    return ListView.builder(
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        final song = _songs[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: Icon(Icons.music_note),
            title:
                Text(song.title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${song.artist} • ${song.genres.join(", ")}'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected: ${song.title}')),
              );
            },
          ),
        );
      },
    );
  }
}
