import 'package:emotion_music_player/views/main_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emotion_music_player/viewmodels/auth_viewmodel.dart';
import 'package:emotion_music_player/views/auth/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }
  Future<void> _checkLoginStatus() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final credentials = await authViewModel.getRememberedCredentials();

    if (credentials != null && credentials.email.isNotEmpty && credentials.password.isNotEmpty) {
      // Attempt to log in with remembered credentials
      bool loggedIn = await authViewModel.login(
        credentials.email, // Now always an email since we reverted to email-only
        credentials.password, 
        true // Pass true for rememberMe to re-save if needed
      );
      
      if (loggedIn && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigator()),
        );
      } else if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
       // If no credentials, or they are invalid, go to LoginScreen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
