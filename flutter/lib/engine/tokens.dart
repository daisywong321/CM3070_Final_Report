import 'package:flutter/material.dart';

/// Design tokens for PlayGarden.
///
/// These values come straight from the design system in the report (section
/// 3.4): bright saturated primaries, large rounded shapes, and a minimum tap
/// target of 88 logical pixels, which is well above the usual 48dp floor and
/// reflects the coarse motor control of four-year-olds.
class Tokens {
  Tokens._();

  // Minimum tap target for a four-year-old (report section 3.4).
  static const double minTapTarget = 88;

  // Corner radius used across cards and buttons.
  static const double radius = 22;

  // Bright, saturated palette used on the home grid.
  static const Color ink = Color(0xFF22223B);
  static const Color inkSoft = Color(0xFF6B6B83);
  static const Color cream = Color(0xFFFDF3E7);

  static const Color red = Color(0xFFFF5A5F);
  static const Color orange = Color(0xFFFF8F3C);
  static const Color yellow = Color(0xFFFFC93C);
  static const Color green = Color(0xFF36C98E);
  static const Color blue = Color(0xFF4A8CFF);
  static const Color purple = Color(0xFF9B6CFF);
  static const Color pink = Color(0xFFFF7FB6);
  static const Color teal = Color(0xFF2EC5D3);

  static const List<Color> confettiColors = [
    red,
    yellow,
    green,
    blue,
    purple,
    pink,
  ];
}
