import 'package:flutter/material.dart';

class AppColors {
  // Warna Hijau
  static const Color primaryGreen = Color(0xFF008000);     // Hijau tua
  static const Color secondaryGreen = Color(0xFF38B000);   // Hijau muda

  // Variasi warna hijau
  // Contoh penggunaan gradient
  static LinearGradient greenGradient = LinearGradient(
    colors: [primaryGreen, secondaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}