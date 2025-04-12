import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/song.dart';

class AudioPlayerService {
  // Singleton pattern
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  // Audio player instance
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();
  final SupabaseClient _supabase = Supabase.instance.client;
  Song? _currentSong;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  AudioPlayer get player => _player;
  Song? get currentSong => _currentSong;

  Stream<PositionData> get positionDataStream =>
      // Combine the position, buffered position, and duration streams into one single stream
      // A stream is a sequence of asynchronous events (e.g., audio position updates)
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(
              position: position,
              bufferedPosition: bufferedPosition,
              duration: duration ?? Duration.zero,
            ),
      );

  Future<void> init() async {
    // Request audio session configuration
    final session = await AudioSession.instance;
    // Configure the audio session for music playback
    await session.configure(AudioSessionConfiguration.music());

    _player.playbackEventStream.listen(
      (event) {
        // Handle playback events
        // For example, you can log the playback state or update UI
      },
      onError: (error, stackTrace) {
        // Handle errors during playback
        print('AudioPlayer error: $error');
      },
    );
  }

  Future<void> playSong(Song song) async {
    _currentSong = song;

    // Set the audio source to the song's URL
    try {
      // Construct the complete file path in the Supabase storage bucket
      // Format: songs/[artist]/[title].mp3
      final filePath = '${song.artist}/${song.title}.mp3';

      // Get the URL of the song from Supabase storage
      final songUrl = await _getSongUrl(filePath);
      if (songUrl == null) {
        throw Exception('Failed to get song URL');
      }

      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(songUrl),
          tag: MediaItem(
              id: song.id,
              title: song.title,
              artist: song.artist,
              // artUri: Uri.parse(song.artworkPath ?? ''), // we don't have this yet
          ),
        ),
      );

      // Start playback
      _player.play();
      return;
    } catch (e) {
      // Handle errors during playback
      print('Error playing song: $e');
    }
  }

  Future<String?> _getSongUrl(String filePath) async {
    try {
      // Get a public URL for the file in the 'songs' bucket
      final response = await _supabase
          .storage
          .from('songs')
          .createSignedUrl(filePath, 3600); // URL valid for 1 hour
      return response;
    } catch (e) {
      print('Error fetching song URL: $e');
      return null;
    }
  }

  Future<void> togglePlayback() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

// This class holds the position data of the audio player
// It includes the current position, buffered position, and total duration
// The buffered audio is the amount of audio that has been loaded and is ready to play
class PositionData {
  final Duration position; // current position of the audio (e.g., 00:01:30)
  final Duration bufferedPosition; // amount of audio buffered
  final Duration duration; // total duration of the audio

  PositionData({
    required this.position,
    required this.bufferedPosition,
    required this.duration,
  });
}