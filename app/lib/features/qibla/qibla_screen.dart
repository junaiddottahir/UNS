import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../location/location_providers.dart';
import 'compass_source.dart';
import 'qibla.dart';
import 'qibla_labels.dart';
import 'qibla_providers.dart';

/// Qibla bearing and a live compass dial. Everything is computed on the
/// phone from the chosen location.
class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bearing = ref.watch(qiblaBearingProvider) ?? 0;
    final place = ref.watch(userLocationProvider)?.city.name ?? '';
    final compass = ref.watch(compassProvider).value;
    final reading = compass is CompassReading ? compass : null;

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const BackTopBar(),
                  Text(place.toUpperCase(), style: AppText.label),
                ],
              ),
              const SizedBox(height: 26),
              Text(l10n.qiblaDirection.toUpperCase(), style: AppText.label),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  text: l10n.degrees(bearing.round() % 360),
                  children: [
                    TextSpan(
                      text:
                          ' ${l10n.compassPointName(compassPointFor(bearing))}',
                      style: const TextStyle(
                        fontSize: 22,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
                style: AppText.bearing,
              ),
              Expanded(
                child: Center(
                  child: QiblaDial(
                    bearing: bearing,
                    heading: reading?.heading ?? 0,
                    live: reading != null,
                    kaabaLabel: l10n.kaaba,
                    northLabel: l10n.compassN,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  0,
                  AppSpacing.screenH,
                  AppSpacing.screenBottom,
                ),
                child: _Footer(state: compass, bearing: bearing),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends ConsumerWidget {
  const _Footer({required this.state, required this.bearing});

  final CompassState? state;
  final double bearing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = switch (state) {
      CompassReading(:final heading) => l10n.guidanceText(
        guidanceFor(turnBy(bearing, heading)),
      ),
      CompassNeedsLocation() => l10n.compassNeedsLocation,
      CompassUnavailable() => l10n.compassUnavailable(bearing.round() % 360),
      null => '',
    };
    final low =
        state is CompassReading &&
        (state as CompassReading).accuracy == HeadingAccuracy.low;

    return Column(
      children: [
        Text(
          status,
          style: const TextStyle(fontSize: 17, color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
        if (low) ...[
          const SizedBox(height: 6),
          Text(
            l10n.compassLowAccuracy,
            style: AppText.body,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 18),
        if (state case CompassNeedsLocation(:final permanently))
          TextLink(
            label: permanently ? l10n.locationOpenSettings : l10n.allowLocation,
            onPressed: () async {
              await ref
                  .read(compassSourceProvider)
                  .allowLocation(openSettings: permanently);
              ref.invalidate(compassProvider);
            },
          )
        else if (state is CompassReading)
          ActionPill(
            icon: const Icon(Icons.refresh),
            label: l10n.calibrate,
            onTap: () => context.push(Routes.qiblaCalibrate),
          ),
      ],
    );
  }
}

/// The prototype's glass dial: turns with the world, with the Kaaba at the
/// qibla bearing and N at north. Facing the qibla puts the Kaaba on top.
class QiblaDial extends StatefulWidget {
  const QiblaDial({
    super.key,
    required this.bearing,
    required this.heading,
    required this.kaabaLabel,
    required this.northLabel,
    required this.live,
  });

  final double bearing;

  /// Whether [heading] comes from a working compass.
  final bool live;
  final double heading;
  final String kaabaLabel;
  final String northLabel;

  @override
  State<QiblaDial> createState() => _QiblaDialState();
}

class _QiblaDialState extends State<QiblaDial> {
  /// Accumulated rotation, so 359° → 1° turns 2°, not back round.
  late double _rotation = -widget.heading;

  @override
  void didUpdateWidget(QiblaDial old) {
    super.didUpdateWidget(old);
    _rotation += turnBy(-widget.heading, _rotation % 360);
  }

  @override
  Widget build(BuildContext context) {
    const size = 270.0;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedRotation(
      turns: _rotation / 360,
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 200),
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
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
            // Kaaba marker and the line from the centre to it.
            Transform.rotate(
              angle: widget.bearing * math.pi / 180,
              child: SizedBox.square(
                dimension: size,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 34,
                      bottom: size / 2,
                      child: Container(
                        width: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.textPrimary, AppColors.track],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -26,
                      // Live, it tilts only by how far off the phone is
                      // (upright when facing). Without a compass the dial
                      // is a still map, so keep it upright on screen.
                      child: Transform.rotate(
                        angle: widget.live
                            ? 0
                            : -widget.bearing * math.pi / 180,
                        child: Image.asset(
                          'assets/images/kaaba.png',
                          width: 48,
                          height: 48,
                          semanticLabel: widget.kaabaLabel,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // North, kept upright relative to the dial.
            Positioned(
              top: 18,
              child: Text(widget.northLabel, style: AppText.label),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
