import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core palette
  static const Color matteBlack = Color(0xFF1A1A1A);
  static const Color electricBlue = Color(0xFF00D4FF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF2A2A2A);
  static const Color mediumGray = Color(0xFF6B6B6B);
  static const Color lightGray = Color(0xFFF0F0F0);

  // Semantic
  static const Color background = matteBlack;
  static const Color surface = darkGray;
  static const Color primary = electricBlue;
  static const Color textPrimary = white;
  static const Color textSecondary = mediumGray;
  static const Color error = Color(0xFFFF4444);
  static const Color success = Color(0xFF44FF88);
  static const Color warning = Color(0xFFFFAA00);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF0088FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
