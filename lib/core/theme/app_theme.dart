import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// "Electric Ink" — TheWedge signature theme.
/// Dark by default. Bold typography, glassy surfaces, electric violet accent.
class AppColors {
  // Base — deep ink black, slightly cool
  static const bg = Color(0xFF0A0A0F);
  static const surface = Color(0xFF15151E);
  static const surfaceElev = Color(0xFF1F1F2B);
  static const surfaceHigh = Color(0xFF26263A);
  static const border = Color(0xFF2A2A38);
  static const borderSubtle = Color(0xFF1F1F2B);

  // Text
  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0xFF9A9AAB);
  static const textTertiary = Color(0xFF5A5A6A);
  static const textInverse = Color(0xFF0A0A0F);

  // Brand — electric violet (the "왜?" curiosity color)
  static const accent = Color(0xFF7C5CFF);
  static const accentLight = Color(0xFF9B7FFF);
  static const accentSoft = Color(0x1A7C5CFF); // 10% violet
  static const accentGlow = Color(0x337C5CFF); // 20% violet

  // Highlight — coral pink (for opinion changes, alerts, energy)
  static const highlight = Color(0xFFFF6B9D);
  static const highlightSoft = Color(0x1AFF6B9D);

  // Status
  static const success = Color(0xFF3DDC97);
  static const warning = Color(0xFFFFB84D);
  static const error = Color(0xFFFF5577);
  static const info = Color(0xFF5AC8FA);

  // Result bars
  static const resultRealtime = Color(0xFF7C5CFF);
  static const resultDeadline = Color(0xFFFF6B9D);
  static const resultBg = Color(0xFF1F1F2B);

  // Social auth
  static const kakaoYellow = Color(0xFFFEE500);
  static const kakaoText = Color(0xFF191919);

  // Persona accent palette (refreshed for dark mode)
  static const personaOpenMinded = Color(0xFF7C5CFF);
  static const personaConviction = Color(0xFFFFB84D);
  static const personaPassionate = Color(0xFFFF6B9D);
  static const personaCalm = Color(0xFF3DDC97);
  static const personaObserver = Color(0xFF8B95A7);
  static const personaBalanced = Color(0xFF5AC8FA);
  static const personaNewcomer = Color(0xFFB8E994);

  // Gradients
  static const gradientHero = LinearGradient(
    colors: [Color(0xFF7C5CFF), Color(0xFFFF6B9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSurface = LinearGradient(
    colors: [Color(0xFF1F1F2B), Color(0xFF15151E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppRadius {
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const pill = 999.0;
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class AppTextStyles {
  static const _family = 'Pretendard';

  // Display — for hero numbers and big stats
  static const display = TextStyle(
    fontFamily: _family,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1.5,
    height: 1.05,
  );

  // Headlines
  static const h1 = TextStyle(
    fontFamily: _family,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.15,
  );

  static const h2 = TextStyle(
    fontFamily: _family,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const h3 = TextStyle(
    fontFamily: _family,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  // Body
  static const bodyLg = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const body = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const bodySm = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  // Label
  static const label = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static const caption = TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 0.3,
  );

  // Button
  static const button = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
  );

  // Mono number — for big stat numbers
  static const number = TextStyle(
    fontFamily: _family,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

class AppTheme {
  static SystemUiOverlayStyle get systemOverlayDark =>
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.bg,
        systemNavigationBarIconBrightness: Brightness.light,
      );

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.accent,
        onPrimary: Colors.white,
        secondary: AppColors.highlight,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        background: AppColors.bg,
        onBackground: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
        surfaceVariant: AppColors.surfaceElev,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        outlineVariant: AppColors.borderSubtle,
      ),
      textTheme: base.textTheme
          .apply(fontFamily: 'Pretendard', bodyColor: AppColors.textPrimary)
          .copyWith(
            displayLarge: AppTextStyles.display,
            headlineLarge: AppTextStyles.h1,
            headlineMedium: AppTextStyles.h2,
            headlineSmall: AppTextStyles.h3,
            titleMedium: AppTextStyles.bodyLg,
            bodyLarge: AppTextStyles.bodyLg,
            bodyMedium: AppTextStyles.body,
            bodySmall: AppTextStyles.bodySm,
            labelLarge: AppTextStyles.button,
            labelMedium: AppTextStyles.label,
            labelSmall: AppTextStyles.caption,
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceElev,
          disabledForegroundColor: AppColors.textTertiary,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentLight,
          textStyle: AppTextStyles.label,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElev,
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElev,
        selectedColor: AppColors.accentSoft,
        labelStyle: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xs)),
        side: const BorderSide(color: AppColors.border),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.accentSoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? AppColors.textPrimary
                : AppColors.textTertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: isSelected
                ? AppColors.accentLight
                : AppColors.textTertiary,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: const TextStyle(
            fontFamily: 'Pretendard',
            color: AppColors.textPrimary,
            fontSize: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceElev,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        titleTextStyle: AppTextStyles.h3,
        contentTextStyle: AppTextStyles.body
            .copyWith(color: AppColors.textSecondary),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.accent,
        thumbColor: AppColors.accent,
        inactiveTrackColor: AppColors.surfaceElev,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: AppTextStyles.label.copyWith(fontSize: 14),
        unselectedLabelStyle: AppTextStyles.body,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(width: 2.5, color: AppColors.accent),
        ),
        dividerColor: AppColors.border,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
    );
  }
}

/// Glassmorphic surface decoration helper.
BoxDecoration glassSurface({
  double radius = AppRadius.lg,
  Color? tint,
  bool elevated = false,
}) {
  return BoxDecoration(
    color: elevated ? AppColors.surfaceElev : AppColors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: tint != null
          ? tint.withOpacity(0.3)
          : AppColors.border,
      width: 1,
    ),
    gradient: tint != null
        ? LinearGradient(
            colors: [tint.withOpacity(0.08), tint.withOpacity(0.02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null,
  );
}
