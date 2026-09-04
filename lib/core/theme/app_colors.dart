import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFF17171E);
  static const surface = Color(0xFF1E1E2A);
  static const surfaceDeep = Color(0xFF12181E);
  static const divider = Color(0xFF33383E);

  static const primary = Color(0xFFFC7E12);
  static const primaryLight = Color(0xFFFC963C);
  static const primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8A8A90);
  static const textTertiary = Color(0xFF606066);

  static const success = Color(0xFF3DD598);
  static const error = Color(0xFFE5484D);

  

  static Color primaryAlpha(int a) => primary.withValues(alpha: a / 255);
}