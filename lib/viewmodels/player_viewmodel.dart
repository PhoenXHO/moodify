import 'package:emotion_music_player/services/audioplayer_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';

import '../models/song.dart';

enum PlaybackSource {
  single,    // Playing a single song (not from playlist or favorites)
  playlist,  // Playing from a playlist
  favorites  // Playing from favorites
}

class PlayerViewModel extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();
  Song? _currentSongOverride;
  
  // Queue management
  List<Song> _queue = [];
  int _currentIndex = -1;
  PlaybackSource? _currentSource = PlaybackSource.single; // Changed to PlaybackSource?
  String? _sourceId; // ID of playlist if source is playlist
  String? get sourceId => _sourceId; // Add getter to prevent unused field warning
  
  // Playback settings
  bool _isShuffleEnabled = false;
  bool _isLoopEnabled = false;
  List<Song>? _originalQueue; // Store original queue order for shuffle
  
  // Auto-play handler
  bool _autoPlayEnabled = false;

  PlayerViewModel() {
    _init();
  }

  Future<void> _init() async {
    await _audioService.init();
    
    // Listen for playback completion to handle auto-play
    _audioService.player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _handleSongCompletion();
      }
    });
  }

  // Getters
  Stream<PlayerState> get playerStateStream => _audioService.playerStateStream;
  Stream<PositionData> get positionDataStream => _audioService.positionDataStream;
  Song? get currentSong => _currentSongOverride ?? _audioService.currentSong;
  bool get hasQueue => _queue.isNotEmpty;
  bool get isShuffleEnabled => _isShuffleEnabled;
  bool get isLoopEnabled => _isLoopEnabled;
  bool get isPlayingFromPlaylistOrFavorites => 
      _currentSource == PlaybackSource.playlist || 
      _currentSource == PlaybackSource.favorites;  // Check if previous/next buttons should be active
  bool get hasPrevious => isPlayingFromPlaylistOrFavorites && 
                         (_isLoopEnabled || _currentIndex > 0);
  bool get hasNext => isPlayingFromPlaylistOrFavorites && 
                     (_isLoopEnabled || _currentIndex < _queue.length - 1);

  // Play a single song (not from playlist or favorites)
  Future<void> playSong(Song song) async {
    _currentSongOverride = null; // Reset override
    _currentSource = PlaybackSource.single;
    _queue = [song];
    _currentIndex = 0;
    _sourceId = null;
    _autoPlayEnabled = false;
    await _audioService.playSong(song);
    notifyListeners();
  }
  
  // Play a song from a playlist
  Future<void> playSongFromPlaylist(Song song, List<Song> playlistSongs, String playlistId) async {
    _currentSongOverride = null;
    _currentSource = PlaybackSource.playlist;
    _queue = List.from(playlistSongs); // Create a copy of the list
    _currentIndex = _queue.indexWhere((s) => s.id == song.id);
    _sourceId = playlistId;
    _autoPlayEnabled = true;
    
    if (_isShuffleEnabled) {
      _setupShuffleQueue(song);
    }
    
    await _audioService.playSong(song);
    notifyListeners();
  }
  
  // Play a song from favorites
  Future<void> playSongFromFavorites(Song song, List<Song> favoriteSongs) async {
    _currentSongOverride = null;
    _currentSource = PlaybackSource.favorites;
    _queue = List.from(favoriteSongs); // Create a copy of the list
    _currentIndex = _queue.indexWhere((s) => s.id == song.id);
    _sourceId = 'favorites';
    _autoPlayEnabled = true;
    
    if (_isShuffleEnabled) {
      _setupShuffleQueue(song);
    }
    
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
    await _audioService.player.pause();
    _currentSongOverride = null;
    _queue = [];
    _currentIndex = 0; // It's conventional to reset index to 0 or -1
    _currentSource = null; // Now valid
    _sourceId = null;
    _audioService.clearCurrentSong();
    notifyListeners();
  }
    // Play previous song in queue
  Future<void> playPrevious() async {
    if (!isPlayingFromPlaylistOrFavorites) return;
    
    if (_currentIndex > 0) {
      _currentIndex--;
    } else if (_isLoopEnabled && _queue.isNotEmpty) {
      // Loop around to the end of the queue
      _currentIndex = _queue.length - 1;
    } else {
      return; // Can't go previous
    }
    
    final previousSong = _queue[_currentIndex];
    await _audioService.playSong(previousSong);
    notifyListeners();
  }
    // Play next song in queue
  Future<void> playNext() async {
    if (!isPlayingFromPlaylistOrFavorites) return;
    
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
    } else if (_isLoopEnabled && _queue.isNotEmpty) {
      // Loop around to the beginning of the queue
      _currentIndex = 0;
    } else {
      return; // Can't go next
    }
    
    final nextSong = _queue[_currentIndex];
    await _audioService.playSong(nextSong);
    notifyListeners();
  }
    // Toggle shuffle mode
  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    
    if (isPlayingFromPlaylistOrFavorites && _queue.isNotEmpty) {
      if (_isShuffleEnabled) {
        // Enable shuffle - make sure we're using the current song
        final currentSong = _queue[_currentIndex];
        _setupShuffleQueue(currentSong);
      } else {
        // Disable shuffle, restore original order
        if (_originalQueue != null) {
          final currentSong = _queue[_currentIndex];
          _queue = List.from(_originalQueue!);
          _currentIndex = _queue.indexWhere((s) => s.id == currentSong.id);
          if (_currentIndex < 0) _currentIndex = 0; // Fallback
          _originalQueue = null;
        }
      }
    }
    
    notifyListeners();
  }
  
  // Toggle loop mode
  void toggleLoop() {
    _isLoopEnabled = !_isLoopEnabled;
    notifyListeners();
  }
    // Handle song completion - auto-play next song if enabled
  void _handleSongCompletion() {
    if (_autoPlayEnabled) {
      if (_currentIndex < _queue.length - 1) {
        // Play next song
        playNext();
      } else if (_isLoopEnabled && _queue.isNotEmpty) {
        // If loop is enabled and we're at the end, go back to start
        _currentIndex = 0;
        final firstSong = _queue[_currentIndex];
        _audioService.playSong(firstSong);
        notifyListeners();
      }
    }
  }
  // Set up shuffled queue, keeping the current song as first
  void _setupShuffleQueue(Song currentSong) {
    // Save original queue if not already saved
    if (_originalQueue == null) {
      _originalQueue = List.from(_queue);
    }
    
    // Create shuffled queue
    final List<Song> shuffled = List.from(_queue);
    
    // Safety check for empty queue
    if (shuffled.isEmpty) return;
    
    // Find and remove the current song
    int currentIndex = -1;
    for (int i = 0; i < shuffled.length; i++) {
      if (shuffled[i].id == currentSong.id) {
        currentIndex = i;
        break;
      }
    }
    
    if (currentIndex != -1) {
      final Song currentSongCopy = shuffled.removeAt(currentIndex);
      
      // Shuffle remaining songs
      if (shuffled.isNotEmpty) {
        final random = Random();
        for (var i = shuffled.length - 1; i > 0; i--) {
          final j = random.nextInt(i + 1);
          final temp = shuffled[i];
          shuffled[i] = shuffled[j];
          shuffled[j] = temp;
        }
      }
      
      // Put current song at the beginning
      shuffled.insert(0, currentSongCopy);
      _queue = shuffled;
      _currentIndex = 0;
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}