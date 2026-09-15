import 'package:flutter/material.dart';
import 'color_manager.dart';
import 'text_styles_manager.dart';

class ThemeManager {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: ColorManager.primaryLight,
      scaffoldBackgroundColor: ColorManager.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: ColorManager.primaryLight,
        secondary: ColorManager.secondaryLight,
        surface: ColorManager.surfaceLight,
        error: ColorManager.errorLight,
      ),
      textTheme: TextTheme(
        displayLarge: TextStylesManager.heading1.copyWith(color: ColorManager.textPrimaryLight),
        displayMedium: TextStylesManager.heading2.copyWith(color: ColorManager.textPrimaryLight),
        titleLarge: TextStylesManager.title.copyWith(color: ColorManager.textPrimaryLight),
        bodyLarge: TextStylesManager.body.copyWith(color: ColorManager.textPrimaryLight),
        bodyMedium: TextStylesManager.body.copyWith(color: ColorManager.textSecondaryLight),
        bodySmall: TextStylesManager.caption.copyWith(color: ColorManager.textSecondaryLight),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ColorManager.surfaceLight,
        iconTheme: const IconThemeData(color: ColorManager.textPrimaryLight),
        titleTextStyle: TextStylesManager.title.copyWith(color: ColorManager.textPrimaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primaryLight,
          foregroundColor: Colors.white,
          textStyle: TextStylesManager.title,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorManager.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorManager.textSecondaryLight.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorManager.textSecondaryLight.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorManager.primaryLight, width: 2),
        ),
        labelStyle: TextStylesManager.body.copyWith(color: ColorManager.textSecondaryLight),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: ColorManager.primaryDark,
      scaffoldBackgroundColor: ColorManager.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: ColorManager.primaryDark,
        secondary: ColorManager.secondaryDark,
        surface: ColorManager.surfaceDark,
        error: ColorManager.errorDark,
      ),
      textTheme: TextTheme(
        displayLarge: TextStylesManager.heading1.copyWith(color: ColorManager.textPrimaryDark),
        displayMedium: TextStylesManager.heading2.copyWith(color: ColorManager.textPrimaryDark),
        titleLarge: TextStylesManager.title.copyWith(color: ColorManager.textPrimaryDark),
        bodyLarge: TextStylesManager.body.copyWith(color: ColorManager.textPrimaryDark),
        bodyMedium: TextStylesManager.body.copyWith(color: ColorManager.textSecondaryDark),
        bodySmall: TextStylesManager.caption.copyWith(color: ColorManager.textSecondaryDark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ColorManager.surfaceDark,
        iconTheme: const IconThemeData(color: ColorManager.textPrimaryDark),
        titleTextStyle: TextStylesManager.title.copyWith(color: ColorManager.textPrimaryDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primaryDark,
          foregroundColor: ColorManager.backgroundDark,
          textStyle: TextStylesManager.title,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorManager.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorManager.textSecondaryDark.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorManager.textSecondaryDark.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorManager.primaryDark, width: 2),
        ),
        labelStyle: TextStylesManager.body.copyWith(color: ColorManager.textSecondaryDark),
      ),
      useMaterial3: true,
    );
  }
}
