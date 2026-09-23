import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// App-wide messenger, so a toast survives navigation (e.g. "Session
/// saved" shown on home after the session screens close).
final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// The prototype's glass toast with a check, near the top.
void showToast(String message) {
  final messenger = rootMessengerKey.currentState;
  if (messenger == null) return;
  final context = rootMessengerKey.currentContext!;
  final top = MediaQuery.paddingOf(context).top;
  final height = MediaQuery.sizeOf(context).height;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.only(bottom: height - top - 120),
        content: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.tabBar,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.glassEdge),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, size: 15, color: AppColors.textPrimary),
                const SizedBox(width: 8),
                // Long messages (or translations) wrap instead of overflowing.
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
}
