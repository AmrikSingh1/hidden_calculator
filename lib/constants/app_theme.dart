import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hidden_calculator/constants/app_constants.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryVariant,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryVariant,
        surface: AppColors.lightSurface,
        background: AppColors.lightBackground,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.lightOnSurface,
        onBackground: AppColors.lightOnBackground,
        onError: AppColors.onError,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.lightBackground,
        titleTextStyle: GoogleFonts.spaceMono(
          color: AppColors.lightOnBackground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.lightOnBackground),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceMono(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppColors.lightOnBackground,
        ),
        displayMedium: GoogleFonts.spaceMono(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.lightOnBackground,
        ),
        displaySmall: GoogleFonts.spaceMono(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.lightOnBackground,
        ),
        headlineMedium: GoogleFonts.spaceMono(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.lightOnBackground,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          color: AppColors.lightOnBackground,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          color: AppColors.lightOnBackground,
        ),
        labelLarge: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.onPrimary,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.onPrimary,
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.lightOnBackground,
        size: 24,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.lightOnBackground,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
  
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryVariant,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryVariant,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurface,
        onBackground: AppColors.onBackground,
        onError: AppColors.onError,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.background,
        titleTextStyle: GoogleFonts.spaceMono(
          color: AppColors.onBackground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.onBackground),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceMono(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppColors.onBackground,
        ),
        displayMedium: GoogleFonts.spaceMono(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.onBackground,
        ),
        displaySmall: GoogleFonts.spaceMono(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.onBackground,
        ),
        headlineMedium: GoogleFonts.spaceMono(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.onBackground,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          color: AppColors.onBackground,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          color: AppColors.onBackground,
        ),
        labelLarge: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.onPrimary,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.onPrimary,
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.onBackground,
        size: 24,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onBackground,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
} 