import 'package:flutter/material.dart';

/// Color tokens from ui-context.md. Widgets use these, never raw hex.
abstract final class AppColors {
  static const bgBase = Color(0xFF140B08);
  static const bgDeep = Color(0xFF0F0A08);
  static const bgSurface = Color(0xFF1C0F0A);
  static const textPrimary = Color(0xFFF3EDE8);
  static const textMuted = Color(0xA6F3EDE8);
  static const textSubtle = Color(0x99F3EDE8);
  static const textFaint = Color(0x4DF3EDE8);
  static const accentPrimary = Color(0xFFE9A37C);
  static const accentStrong = Color(0xFFC0603A);
  static const accentDeep = Color(0xFFB8472A);
  static const accentShadow = Color(0xFF5A2412);
  static const borderDefault = Color(0x1AF3EDE8);
  static const track = Color(0x38F3EDE8);

  /// Frosted "glass" panels and option pills over background photos.
  static const glassFill = Color(0x14FFFFFF);
  static const glassEdge = Color(0x24FFFFFF);
  static const pillFill = Color(0x1AFFFFFF);
  static const pillEdge = Color(0x29FFFFFF);
  static const pillSelected = Color(0xF0F3EDE8);
  static const tabBar = Color(0x803A2016);

  /// Primary call-to-action: cream pill with dark text.
  static const ctaBackground = textPrimary;
  static const ctaForeground = bgSurface;
}
