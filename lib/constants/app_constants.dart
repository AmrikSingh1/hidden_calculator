import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);
  
  // Calculator colors
  static const Color calculatorBackground = Color(0xFF121212);
  static const Color operatorButton = Color(0xFFFFA000);
  static const Color numberButton = Color(0xFF333333);
  static const Color functionButton = Color(0xFF616161);
  
  // Theme colors
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color error = Color(0xFFCF6679);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Colors.white;
  static const Color onSurface = Colors.white;
  static const Color onError = Colors.black;
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
  
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;
  
  static const double calculatorButtonSize = 70.0;
  static const double calculatorButtonPadding = 12.0;
}

class AppAnimations {
  static const String lockAnimation = 'assets/animations/lock.json';
  static const String unlockAnimation = 'assets/animations/unlock.json';
} 