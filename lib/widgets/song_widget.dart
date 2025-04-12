import 'package:emotion_music_player/viewmodels/player_viewmodel.dart';
import 'package:emotion_music_player/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:emotion_music_player/models/song.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/snackbar.dart';

class SongWidget extends StatefulWidget {
  final Song song;
  final Function onFavoriteToggle;

  const SongWidget({
    super.key,
    required this.song,
    required this.onFavoriteToggle,
  });

  @override
  State<SongWidget> createState() => _SongWidgetState();
}

class _SongWidgetState extends State<SongWidget> {
  final supabase = Supabase.instance.client;
  bool _isLoading = false;

  Future<void> _toggleFavorite() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the callback function to update the parent widget
      widget.onFavoriteToggle(widget.song.id);
    } catch (e) {
      showSnackBar(context, 'Error toggling favorite: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Visual treatment for unfavorited songs
    final isUnfavorited = !widget.song.isFavorite;
    final playerViewModel = Provider.of<PlayerViewModel>(context, listen: false);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: isUnfavorited ? Colors.grey[200] : null,
      child: ListTile(
        title: Text(
          widget.song.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnfavorited ? Colors.grey : null,
          ),
        ),
        subtitle: Text(widget.song.artist),
        trailing: _isLoading
            ? const SizedBox(
                width: 24, 
                height: 24, 
                child: CircularProgressIndicator(strokeWidth: 2)
              )
            : IconButton(
                icon: Icon(
                  widget.song.isFavorite 
                      ? Icons.favorite 
                      : Icons.favorite_border,
                  color: widget.song.isFavorite ? Colors.red : null,
                ),
                onPressed: _toggleFavorite,
              ),
        onTap: () async {
          await playerViewModel.playSong(widget.song);
        },
      ),
    );
  }
}
