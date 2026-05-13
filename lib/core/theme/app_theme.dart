import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const primary = Color(0xFF1A1A2E);
  static const secondary = Color(0xFF16213E);
  static const accent = Color(0xFF0F3460);
  static const highlight = Color(0xFFE94560);

  // Neutral
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F3F5);
  static const border = Color(0xFFE9ECEF);

  // Text
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6C757D);
  static const textTertiary = Color(0xFFADB5BD);

  // Status
  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFF39C12);
  static const error = Color(0xFFE74C3C);
  static const info = Color(0xFF3498DB);

  // Poll result bar
  static const resultBar = Color(0xFF0F3460);
  static const resultBarDeadline = Color(0xFFE94560);
  static const resultBarBackground = Color(0xFFEEF2FF);

  // Social auth
  static const kakaoYellow = Color(0xFFFEE500);
  static const kakaoText = Color(0xFF191919);
  static const googleWhite = Color(0xFFFFFFFF);
  static const appleDark = Color(0xFF000000);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.light,
        primary: AppColors.accent,
        secondary: AppColors.highlight,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Pretendard',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.accent.withOpacity(0.12),
        labelStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }
}
