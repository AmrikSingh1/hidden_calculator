import 'package:flutter/material.dart';

class AppColors {
  // Primary and accent colors
  static const primary = Color(0xFF4A6BF8);
  static const primaryVariant = Color(0xFF3B5CEA);
  static const secondary = Color(0xFF25CAFC);
  static const secondaryVariant = Color(0xFF00A6D8);
  static const error = Color(0xFFE53935);

  // Text colors
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSecondary = Color(0xFF000000);
  static const onError = Color(0xFFFFFFFF);

  // Dark theme colors
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const onBackground = Color(0xFFF5F5F5);
  static const onSurface = Color(0xFFE0E0E0);
  
  // Light theme colors
  static const lightBackground = Color(0xFFF5F5F5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightOnBackground = Color(0xFF212121);
  static const lightOnSurface = Color(0xFF424242);

  // Calculator colors
  static const calculatorBackground = Color(0xFF121212);
  static const calculatorDisplay = Color(0xFF1E1E1E);
  static const calculatorText = Color(0xFFF5F5F5);
  static const calculatorOperator = Color(0xFF4A6BF8);
  static const calculatorButton = Color(0xFF2A2A2A);
  static const calculatorButtonText = Color(0xFFF5F5F5);
  static const calculatorEqual = Color(0xFF4A6BF8);
  static const calculatorEqualText = Color(0xFFFFFFFF);
  static const calculatorClear = Color(0xFFE53935);
  static const calculatorClearText = Color(0xFFFFFFFF);
}

class AppStrings {
  // App
  static const String appName = "Calculator";
  static const String hiddenAppName = "Vault";
  
  // Calculator buttons
  static const String clear = "C";
  static const String divide = "÷";
  static const String multiply = "×";
  static const String subtract = "-";
  static const String add = "+";
  static const String equals = "=";
  static const String decimal = ".";
  static const String percent = "%";
  static const String plusMinus = "+/-";
  
  // Vault categories
  static const String photos = "Photos";
  static const String videos = "Videos";
  static const String documents = "Documents";
  static const String notes = "Notes";
}

class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 16.0;
  
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  
  static const double calculatorButtonSize = 70.0;
  static const double calculatorButtonPadding = 12.0;
}

class AppAnimations {
  static const String lockAnimation = 'assets/animations/lock.json';
  static const String unlockAnimation = 'assets/animations/unlock.json';
} 