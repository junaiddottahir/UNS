import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Which bottom fade to lay over the background image.
enum BackgroundFade {
  /// Strong fade to black at the bottom, for screens with text low down.
  bottom,

  /// Gentler fade, for step screens with content from the top.
  soft,
}

/// Full-bleed background photo with the prototype's gradient overlay.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    super.key,
    this.image = 'assets/images/bg_default.jpg',
    this.fade = BackgroundFade.soft,
    required this.child,
  });

  final String image;
  final BackgroundFade fade;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final (stops, colors) = switch (fade) {
      BackgroundFade.bottom => (
        const [0.0, 0.3, 0.5, 0.76, 1.0],
        [
          AppColors.bgDeep.withValues(alpha: 0.55),
          AppColors.bgDeep.withValues(alpha: 0),
          AppColors.bgDeep.withValues(alpha: 0.15),
          AppColors.bgDeep.withValues(alpha: 0.9),
          AppColors.bgDeep,
        ],
      ),
      BackgroundFade.soft => (
        const [0.0, 0.3, 0.6, 1.0],
        [
          AppColors.bgDeep.withValues(alpha: 0.55),
          AppColors.bgDeep.withValues(alpha: 0),
          AppColors.bgDeep.withValues(alpha: 0.35),
          AppColors.bgDeep.withValues(alpha: 0.8),
        ],
      ),
    };

    return ColoredBox(
      color: AppColors.bgDeep,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(image, fit: BoxFit.cover),
          Opacity(
            opacity: 0.5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: stops,
                  colors: colors,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
