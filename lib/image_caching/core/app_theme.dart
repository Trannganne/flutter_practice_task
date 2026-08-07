// lib/core/theme/app_colors.dart

// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Cấu hình Theme Sáng
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        surface: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        secondary: AppColors.lightTextSecondary,
      ),
      // Tùy chỉnh kiểu chữ chung cho toàn bộ app
      textTheme: const TextTheme(
        titleMedium: TextStyle(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
      ),
    );
  }

  // Cấu hình Theme Tối
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF1E1E1E),
        onSurface: AppColors.darkTextPrimary,
        secondary: AppColors.darkTextSecondary,
      ),
      textTheme: const TextTheme(
        titleMedium: TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
      ),
    );
  }
}
