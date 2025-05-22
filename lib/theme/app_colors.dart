import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFFBE233D); // Pink accent color
  static const Color background = Color(0xFF000000); // Pure black
  static const Color surface = Color(0xFF121212); // Dark surface
  static const Color surfaceLight = Color(0xFF1E1E1E); // Lighter surface

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB3B3B3); // Light gray

  // UI Element colors
  static const Color cardBackground = Color(0xFF1C1C1C);
  static const Color divider = Color(0xFF2C2C2C);
  static const Color inactive = Color(0xFF4D4D4D); // Gray for inactive elements
  
  // Mini player colors
  static const Color miniPlayerBackground = Color(0xFF1C1B1B);
  static const Color progressBackground = Color(0xFF4F4F4F);
  static const Color progressBar = primary;
  
  // Button colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = Colors.white;
  
  // Indicator colors
  static const Color activeIndicator = primary;
  static const Color inactiveIndicator = Color(0xFF4D4D4D);
}
