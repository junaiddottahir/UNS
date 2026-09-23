import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The prototype's cream voice button with a soft pulse behind it. The
/// pulse stops when the phone asks for reduced motion.
class MoodOrb extends StatefulWidget {
  const MoodOrb({super.key, required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  State<MoodOrb> createState() => _MoodOrbState();
}

class _MoodOrbState extends State<MoodOrb> with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 60,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              // 0 → 0.5 → 1: grow to 1.25× and fade out, then back.
              final t = 1 - (2 * _pulse.value - 1).abs();
              return Transform.scale(
                scale: 1 + 0.25 * t,
                child: Opacity(
                  opacity: _pulse.isAnimating ? 0.5 * (1 - t) : 0,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textPrimary,
                    ),
                    child: SizedBox.expand(),
                  ),
                ),
              );
            },
          ),
          Semantics(
            button: true,
            label: widget.label,
            excludeSemantics: true,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x59B0482A),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: SizedBox.expand(
                child: FilledButton(
                  onPressed: widget.onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ctaBackground,
                    foregroundColor: AppColors.ctaForeground,
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.graphic_eq, size: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
