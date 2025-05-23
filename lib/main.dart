import 'package:emotion_music_player/viewmodels/emotion_viewmodel.dart';
import 'package:emotion_music_player/viewmodels/playlists_viewmodel.dart';
import 'package:emotion_music_player/viewmodels/auth_viewmodel.dart';
import 'package:emotion_music_player/viewmodels/chat_viewmodel.dart';
import 'package:emotion_music_player/viewmodels/favorites_viewmodel.dart';
import 'package:emotion_music_player/viewmodels/player_viewmodel.dart';
import 'package:emotion_music_player/views/auth/login.dart';
import 'package:emotion_music_player/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize JustAudio background playback
  await JustAudioBackground.init(
    androidNotificationChannelId:
        'com.example.emotion_music_player.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  // Load the .env file
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (context) => PlayerViewModel()),
        ChangeNotifierProvider(create: (context) => PlaylistsViewModel()),
        ChangeNotifierProvider(create: (context) => ChatViewModel()),
         ChangeNotifierProxyProvider<ChatViewModel, EmotionViewModel>(
      create: (context) => EmotionViewModel(
        Provider.of<ChatViewModel>(context, listen: false),
      ),
      update: (context, chatViewModel, previousEmotionViewModel) => 
        previousEmotionViewModel ?? EmotionViewModel(chatViewModel),
    ),
      ],      child: MaterialApp(
          title: 'Moodify',
          theme: AppTheme.theme,
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginScreen(),
            '/login': (context) => const LoginScreen(),
          },
      ),
    );
  }
}
