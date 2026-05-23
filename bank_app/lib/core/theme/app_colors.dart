import 'package:flutter/material.dart';

/// Fintech app design token colors — mirrors the Stitch design token colors.
abstract final class AppColors {
  static const Color surface = Color(0xFF131313);
  static const Color onSurface = Color(0xFFE2E2E2);
  static const Color background = Color(0xFF131313);
  static const Color outlineVariant = Color(0xFF444933);
  static const Color primaryFixed = Color(0xFFC3F400);
  static const Color primaryFixedDim = Color(0xFFABD600);
  
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF1B1B1B);
  static const Color surfaceContainer = Color(0xFF1F1F1F);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353535);
  
  static const Color primary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFC8C6C5);
  static const Color onSurfaceVariant = Color(0xFFC4C9AC);
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  
  // Custom Card Deep Dark
  static const Color cardBg = Color(0xFF0C0C0C);

  // --- Legacy Compatibility Aliases ---
  static const Color brandLime = primaryFixed;
  static const Color brandLimeDim = primaryFixedDim;
  static const Color textPrimary = primary;
  static const Color textSecondary = secondary;
  static const Color textMuted = Color(0xFF474746);
  static const Color surfaceBorder = outlineVariant;
  static const Color backgroundDeep = surfaceContainerLowest;
  static const Color divider = outlineVariant;
}
