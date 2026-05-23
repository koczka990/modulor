import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background       = Color(0xFFF8F9FA);
  static const surfaceContainer = Color(0xFFEDEEEF);
  static const primary          = Color(0xFFB7102A);
  static const secondaryContainer = Color(0xFFFFD167);
  static const tertiaryContainer  = Color(0xFF007EA4);
  static const ink              = Color(0xFF191C1D);

  // Piece fill colors (model: red → red, blue → teal, green → yellow)
  static const pieceRed    = Color(0xFFB7102A);
  static const pieceBlue   = Color(0xFF007EA4);
  static const pieceYellow = Color(0xFFFFD167);

  // Clue header colors cycle by index
  static const clueHeaderBg = [primary, secondaryContainer, tertiaryContainer];
  static const clueHeaderFg = [Color(0xFFFFFFFF), ink, Color(0xFFFFFFFF)];
}
