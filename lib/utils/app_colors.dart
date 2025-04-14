import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryRed = Color(0xFFE63946);
  static const Color backgroundGradientStart = Color(0xFF3A1C71);
  static const Color backgroundGradientEnd = Color(0xFFD76D77);

  static const Color sosButtonColor = Colors.redAccent;
  static const Color dialogBackground = Colors.white;
  static const Color dialogTextColor = Colors.black87;
  static const Color dialogButtonColor = Colors.blueAccent;

  static LinearGradient get primaryGradient => LinearGradient(
    colors: [
      Colors.white.withOpacity(0.9),
      Colors.grey[300]!.withOpacity(0.7),
      Colors.white.withOpacity(0.9),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
