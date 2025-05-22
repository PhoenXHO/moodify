import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'dimensions.dart';
import 'text_styles.dart';

/// Main application theme
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();
  
  /// Get the main app theme
  static ThemeData get theme {
    return ThemeData(
      // Base colors and brightness
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primary,
        background: AppColors.background,
        surface: AppColors.surface,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      
      // General app styling
      scaffoldBackgroundColor: AppColors.background,
      
      // AppBar styling
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      
      // Button styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.m,
            vertical: Dimensions.s,
          ),
        ),
      ),
      
      // Card styling
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: Dimensions.elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.borderRadiusMedium),
        ),
      ),
      
      // Bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.inactive,
      ),
      
      // List tile styling
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textPrimary,
      ),
      
      // Slider styling for audio player
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.progressBackground,
        thumbColor: AppColors.primary,
        trackHeight: 2.0,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 6.0,
        ),
      ),
      
      // Dialog styling
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.borderRadiusMedium),
        ),
      ),
      
      // Text field styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.borderRadiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      
      // Text styling
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.h1,
        displayMedium: AppTextStyles.h2,
        displaySmall: AppTextStyles.h3,
        bodyLarge: AppTextStyles.body1,
        bodyMedium: AppTextStyles.body2,
        labelMedium: AppTextStyles.label,
        labelLarge: AppTextStyles.button,
      ),
    );
  }
}
