import 'package:emotion_music_player/services/audioplayer_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';

class PlayerViewModel extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();
  Song? _currentSongOverride; // Add this line

  PlayerViewModel() {
    _init();
  }

  Future<void> _init() async {
    await _audioService.init();
  }

  Future<void> init() async {
    await _audioService.init();
  }

  Stream<PlayerState> get playerStateStream => _audioService.playerStateStream;
  Stream<PositionData> get positionDataStream => _audioService.positionDataStream;

  // Modify currentSong getter
  Song? get currentSong => _currentSongOverride ?? _audioService.currentSong;

  Future<void> playSong(Song song) async {
    _currentSongOverride = null; // Reset override when a new song plays
    await _audioService.playSong(song);
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    await _audioService.togglePlayback();
    notifyListeners();
  }
  Future<void> seekTo(Duration position) async {
    await _audioService.seek(position);
    notifyListeners();
  }

  Future<void> closePlayer() async {
    // Pause the playback
    await _audioService.player.pause();
    
    // Set override to null to hide the mini player
    _currentSongOverride = null;
    
    notifyListeners();
  }


  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}