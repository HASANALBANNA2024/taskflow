import 'package:flutter/material.dart';

/// Design tokens lifted directly from the approved UI mockup
/// (task_manager_ui_mockup.html) so the app and the mockup stay in sync.
class AppColors {
  AppColors._();

  static const paper = Color(0xFFEEF0E9);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF20261F);
  static const inkSoft = Color(0xFF5B6459);
  static const inkFaint = Color(0xFF8B9385);
  static const line = Color(0xFFDFE3D8);

  static const moss = Color(0xFF3D5A45);
  static const mossDeep = Color(0xFF2A4030);
  static const mossTint = Color(0xFFE3EAE0);

  static const amber = Color(0xFFC9762A);
  static const amberTint = Color(0xFFF7E7D3);

  static const brick = Color(0xFFB3492F);
  static const brickTint = Color(0xFFF5DED7);

  static const chipNeutral = Color(0xFFEDEEE7);
}

class AppRadius {
  AppRadius._();
  static const sm = 12.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 24.0;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Manrope',
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.moss,
        primary: AppColors.moss,
        secondary: AppColors.amber,
        error: AppColors.brick,
        surface: AppColors.surface,
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.line, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.moss, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.brick, width: 1.6),
        ),
        labelStyle: const TextStyle(
            color: AppColors.inkSoft,
            fontWeight: FontWeight.w700,
            fontSize: 12.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.moss,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.moss,
          side: const BorderSide(color: AppColors.moss, width: 1.6),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
    );
  }
}
