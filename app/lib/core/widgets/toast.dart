import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// The app's root navigator, so a toast can outlive the screen that showed
/// it (e.g. "Session saved" appearing on home).
final rootNavigatorKey = GlobalKey<NavigatorState>();

OverlayEntry? _current;

/// The prototype's glass toast with a check, near the top. Touches pass
/// straight through it, so it never blocks what's underneath.
void showToast(String message) {
  final overlay = rootNavigatorKey.currentState?.overlay;
  if (overlay == null) return;
  _current?.remove();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _Toast(
      message: message,
      onDone: () {
        if (entry.mounted) entry.remove();
        if (_current == entry) _current = null;
      },
    ),
  );
  _current = entry;
  overlay.insert(entry);
}

/// Owns its timer, so the timer goes away with the toast.
class _Toast extends StatefulWidget {
  const _Toast({required this.message, required this.onDone});

  final String message;
  final VoidCallback onDone;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), widget.onDone);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 16,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Center(
          child: Material(
            type: MaterialType.transparency,
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
                  const Icon(
                    Icons.check,
                    size: 15,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  // Long messages (or translations) wrap.
                  Flexible(
                    child: Text(
                      widget.message,
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
      ),
    );
  }
}
