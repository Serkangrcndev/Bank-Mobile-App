import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Global MaterialApp ThemeData for the Fintech app.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryFixed,
      onPrimary: Color(0xFF283500),
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      outline: AppColors.outlineVariant,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    // Remove all default splash / highlight effects
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    focusColor: Colors.transparent,
  );
}
