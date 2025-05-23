import 'package:flutter/material.dart';
import '../widgets/bottomnav.dart';

/// A simple navigator wrapper for the BottomNav
class MainNavigator extends StatelessWidget {
  const MainNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return const BottomNav();
  }
}