import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  // --- Headline XL  (40px / 48px / Inter 700 / -0.02em)
  static TextStyle headlineXl({Color color = AppColors.primary}) =>
      GoogleFonts.inter(
        fontSize: 40,
        height: 48 / 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 40,
        color: color,
      );

  // --- Headline LG  (32px / 40px / Inter 700 / -0.02em)
  static TextStyle headlineLg({Color color = AppColors.primary}) =>
      GoogleFonts.inter(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 32,
        color: color,
      );

  // --- Headline LG Mobile  (24px / 32px / Inter 700)
  static TextStyle headlineLgMobile({Color color = AppColors.primary}) =>
      GoogleFonts.inter(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w700,
        color: color,
      );

  // --- Headline MD  (20px / 28px / Inter 600)
  static TextStyle headlineMd({Color color = AppColors.primary}) =>
      GoogleFonts.inter(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // --- Body LG  (18px / 26px / Inter 400)
  static TextStyle bodyLg({Color color = AppColors.primary}) =>
      GoogleFonts.inter(
        fontSize: 18,
        height: 26 / 18,
        fontWeight: FontWeight.w400,
        color: color,
      );

  // --- Body MD  (16px / 24px / Inter 400)
  static TextStyle bodyMd({Color color = AppColors.primary}) =>
      GoogleFonts.inter(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: color,
      );

  // --- Label MD  (14px / 20px / JetBrains Mono 500 / +0.05em)
  static TextStyle labelMd({Color color = AppColors.primary}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.05 * 14,
        color: color,
      );

  // --- Label SM  (12px / 16px / JetBrains Mono 500 / +0.05em)
  static TextStyle labelSm({Color color = AppColors.primary}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.05 * 12,
        color: color,
      );
}
