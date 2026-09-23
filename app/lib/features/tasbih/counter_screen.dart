import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import 'dhikr_labels.dart';
import 'tasbih_providers.dart';

/// Tap anywhere to count. At the target it vibrates, then moves to the
/// next dhikr in the set, or to History when the session is done.
class CounterScreen extends ConsumerStatefulWidget {
  const CounterScreen({super.key});

  @override
  ConsumerState<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends ConsumerState<CounterScreen> {
  Timer? _next;
  bool _pressed = false;

  void _tap() {
    final result = ref.read(tasbihSessionProvider.notifier).tap();
    if (result == TapResult.ignored) return;
    setState(() => _pressed = true);
    Future.delayed(const Duration(milliseconds: 110), () {
      if (mounted) setState(() => _pressed = false);
    });
    if (result == TapResult.reachedTarget) {
      _next = Timer(targetPause, () {
        if (!mounted) return;
        final more = ref.read(tasbihSessionProvider.notifier).advance();
        if (!more) context.pushReplacement('${Routes.tasbihHistory}?done=1');
      });
    }
  }

  @override
  void dispose() {
    _next?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(tasbihSessionProvider);
    if (session == null) return const Scaffold();
    final dhikr = session.dhikr;

    return Scaffold(
      body: AmbientBackground(
        image: 'assets/images/bg_tasbih.jpg',
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  BackTopBar(
                    trailing: IconButton(
                      onPressed: ref.read(tasbihSessionProvider.notifier).reset,
                      icon: const Icon(
                        Icons.restart_alt,
                        color: AppColors.textPrimary,
                      ),
                      tooltip: l10n.startOver,
                    ),
                  ),
                  Text(
                    (session.isSet
                            ? l10n.stepOf(session.index + 1, session.set.length)
                            : l10n.singleDhikr)
                        .toUpperCase(),
                    style: AppText.label,
                  ),
                ],
              ),
              Expanded(
                child: Semantics(
                  button: true,
                  label: l10n.tasbihCount(session.count, dhikr.target),
                  excludeSemantics: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _tap,
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Text(l10n.dhikrName(dhikr), style: AppText.title2),
                        Expanded(
                          child: Center(
                            child: AnimatedScale(
                              scale: _pressed ? 0.97 : 1,
                              duration: const Duration(milliseconds: 120),
                              child: _CountRing(
                                count: session.count,
                                target: dhikr.target,
                                ofTarget: l10n.ofTarget(dhikr.target),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 60),
                          child: Text(
                            (session.atTarget
                                    ? l10n.complete
                                    : l10n.tapAnywhere)
                                .toUpperCase(),
                            style: AppText.label,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountRing extends StatelessWidget {
  const _CountRing({
    required this.count,
    required this.target,
    required this.ofTarget,
  });

  final int count;
  final int target;
  final String ofTarget;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.glassFill,
                  border: Border.all(color: AppColors.glassEdge),
                ),
              ),
            ),
          ),
          SizedBox.expand(
            child: CustomPaint(
              painter: _RingPainter(progress: (count / target).clamp(0, 1)),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$count', style: AppText.counter),
              const SizedBox(height: 6),
              Text(ofTarget.toUpperCase(), style: AppText.label),
            ],
          ),
        ],
      ),
    );
  }
}

/// A 3px arc from the top, clockwise, as far as [progress].
class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    const stroke = 3.0;
    final rect = Offset.zero & size;
    canvas.drawArc(
      rect.deflate(stroke / 2),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = AppColors.textPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
