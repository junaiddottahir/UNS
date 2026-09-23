import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Radius scale from ui-context.md.
abstract final class AppRadius {
  static const pill = 999.0;
  static const card = 26.0;
}

/// Spacing used by full-screen layouts in the prototype.
abstract final class AppSpacing {
  static const screenH = 26.0;
  static const screenBottom = 50.0;
}

/// Text styles matching the prototype's `.h`, `.p`, `.lbl` and `.tx` classes.
abstract final class AppText {
  static const headline = TextStyle(
    fontSize: 36,
    height: 1.05,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.08,
    color: AppColors.textPrimary,
  );
  static const title = TextStyle(
    fontSize: 32,
    height: 1.05,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.96,
    color: AppColors.textPrimary,
  );
  static const body = TextStyle(
    fontSize: 15,
    height: 1.45,
    color: AppColors.textMuted,
  );
  static const label = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.6,
    color: AppColors.textSubtle,
  );
  static const link = TextStyle(fontSize: 15, color: Color(0xCCF3EDE8));
  static const input = TextStyle(fontSize: 24, color: AppColors.textPrimary);
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme.dark(
    surface: AppColors.bgBase,
    primary: AppColors.accentPrimary,
    secondary: AppColors.accentStrong,
    onSurface: AppColors.textPrimary,
    onPrimary: AppColors.bgDeep,
    outline: AppColors.borderDefault,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bgDeep,
    // TODO: switch to Athletics once the licensed font files are in assets/fonts.
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.accentStrong,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
      ),
    ),
  );
}
