import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Application typography styles
class AppTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle h2 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle h3 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
  );
  
  // Body text
  static const TextStyle body1 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle body2 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
  );
  
  // Secondary text
  static const TextStyle secondary = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle secondarySmall = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
  );
  
  // Labels
  static const TextStyle label = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
  );
  
  // Button text
  static const TextStyle button = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );
  
  // Playlist styles
  static const TextStyle playlistTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle playlistSubtitle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
  );
  
  // Mini player styles
  static const TextStyle songTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle artistName = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
  );
}
