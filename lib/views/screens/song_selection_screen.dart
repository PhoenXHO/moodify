import 'package:emotion_music_player/models/song.dart';
import 'package:emotion_music_player/theme/dimensions.dart';
import 'package:emotion_music_player/viewmodels/playlists_viewmodel.dart';
import 'package:emotion_music_player/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SongSelectionScreen extends StatefulWidget {
  final String playlistId;

  const SongSelectionScreen({super.key, required this.playlistId});

  @override
  State<SongSelectionScreen> createState() => _SongSelectionScreenState();
}

class _SongSelectionScreenState extends State<SongSelectionScreen> {
  final Set<String> _selectedSongs = {};
  bool _isLoading = true;
  List<Song> _songs = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print("🔄 SongSelectionScreen: Loading songs directly");

      final viewModel = Provider.of<PlaylistsViewModel>(context, listen: false);
      final songs = await viewModel.getAllSongs(widget.playlistId);

      if (mounted) {
        setState(() {
          _songs = songs;
          _isLoading = false;
          print("✅ SongSelectionScreen: Loaded ${songs.length} songs");
        });
      }
    } catch (e) {
      print("❌ SongSelectionScreen: Error loading songs: $e");
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Songs to Playlist'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _selectedSongs.isNotEmpty ? _addSelectedSongs : null,
            child: Text(
              'Add (${_selectedSongs.length})',
              style: TextStyle(
                color: _selectedSongs.isNotEmpty ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading songs...", style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: Dimensions.iconSizeLarge), // Use Dimensions
            SizedBox(height: 16),
            Text('Error: $_error', style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSongs,
              child: Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, color: Colors.grey, size: Dimensions.iconSizeLarge), // Use Dimensions
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

    return ListView.builder(
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        final song = _songs[index];
        final isSelected = _selectedSongs.contains(song.id);

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.music_note, size: Dimensions.iconSize), // Use Dimensions
            title:
                Text(song.title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(song.artist),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedSongs.add(song.id);
                  } else {
                    _selectedSongs.remove(song.id);
                  }
                });
              },
            ),
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedSongs.remove(song.id);
                } else {
                  _selectedSongs.add(song.id);
                }
              });
            },
          ),
        );
      },
    );
  }

  void _addSelectedSongs() async {
    final playlistViewModel =
        Provider.of<PlaylistsViewModel>(context, listen: false);

    for (final songId in _selectedSongs) {
      await playlistViewModel.addSongToPlaylist(widget.playlistId, songId);
    }

    if (mounted) {
      showSnackBar(context, '${_selectedSongs.length} songs added to playlist');
      Navigator.pop(context);
    }
  }
}
