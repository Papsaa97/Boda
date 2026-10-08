import 'package:flutter/material.dart';

/// Barvy tmavého motivu (specifikace, kap. 10.2).
abstract final class AppColors {
  static const background = Color(0xFF020617);
  static const surface = Color(0xFF0F172A);
  static const surfaceHigh = Color(0xFF1E293B);
  static const teal = Color(0xFF2DD4BF);
  static const green = Color(0xFF10B981);
  static const orange = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
}

/// Barvy světlého motivu (specifikace, kap. 10.2). Tyrkysová `#2DD4BF`
/// na bílé nemá dost kontrastu pro text, proto je primární barva tmavší.
abstract final class AppLightColors {
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceHigh = Color(0xFFF1F5F9);
  static const text = Color(0xFF0F172A);
  static const teal = Color(0xFF0F766E);
  static const green = Color(0xFF047857);
  static const orange = Color(0xFFB45309);
  static const red = Color(0xFFB91C1C);
}

abstract final class AppTheme {
  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.teal,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.teal,
          onPrimary: AppColors.background,
          secondary: AppColors.green,
          tertiary: AppColors.orange,
          error: AppColors.red,
          surface: AppColors.surface,
          surfaceContainerHighest: AppColors.surfaceHigh,
          surfaceContainerHigh: AppColors.surfaceHigh,
          surfaceContainer: AppColors.surfaceHigh,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: Color(0x332DD4BF),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }

  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppLightColors.teal,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppLightColors.teal,
          onPrimary: Colors.white,
          secondary: AppLightColors.green,
          tertiary: AppLightColors.orange,
          error: AppLightColors.red,
          surface: AppLightColors.surface,
          onSurface: AppLightColors.text,
          surfaceContainerHighest: AppLightColors.surfaceHigh,
          surfaceContainerHigh: AppLightColors.surfaceHigh,
          surfaceContainer: AppLightColors.surfaceHigh,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppLightColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppLightColors.background,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppLightColors.surfaceHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppLightColors.surface,
        indicatorColor: Color(0x330F766E),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
