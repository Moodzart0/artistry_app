import 'package:flutter/material.dart';

/// Centralized color palette for the Artistry app.
class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF4A3DB5);

  // Accent / secondary
  static const Color accent = Color(0xFFFF6B9D);
  static const Color accentLight = Color(0xFFFF9EC5);

  // Neutral
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  static const Color onBackground = Color(0xFF212529);
  static const Color onSurface = Color(0xFF343A40);
  static const Color onSurfaceVariant = Color(0xFF868E96);

  // Dark theme
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);

  // Semantic
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFE17055);
  static const Color info = Color(0xFF74B9FF);

  // Canvas
  static const Color canvasBackground = Color(0xFFE9ECEF);
  static const Color canvasGrid = Color(0xFFDEE2E6);
}
