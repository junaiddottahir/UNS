import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../location/city.dart';
import '../location/device_locator.dart';
import '../location/location_providers.dart';

/// Onboarding step 1: device location, with a manual city fallback.
class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  bool _locating = false;
  DeviceLocationResult? _problem;

  Future<void> _useMyLocation() async {
    setState(() {
      _locating = true;
      _problem = null;
    });

    final result = await ref.read(deviceLocatorProvider).locate();
    if (!mounted) return;

    if (result is DeviceLocationFound) {
      final cities = await ref.read(cityRepositoryProvider.future);
      final city = cities.nearest(result.latitude, result.longitude);
      ref
          .read(userLocationProvider.notifier)
          .set(
            UserLocation(
              city: city,
              latitude: result.latitude,
              longitude: result.longitude,
              source: LocationSource.device,
            ),
          );
      if (!mounted) return;
      setState(() => _locating = false);
      context.push(Routes.prayerStep);
    } else {
      setState(() {
        _locating = false;
        _problem = result;
      });
    }
  }

  String? _problemText(AppLocalizations l10n) => switch (_problem) {
    DeviceLocationDenied(permanently: true) => l10n.locationDeniedForever,
    DeviceLocationDenied() => l10n.locationDenied,
    DeviceLocationServiceOff() => l10n.locationServiceOff,
    DeviceLocationFailed() => l10n.locationFailed,
    DeviceLocationFound() || null => null,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final problem = _problemText(l10n);
    final canOpenSettings =
        _problem is DeviceLocationDenied &&
        (_problem as DeviceLocationDenied).permanently;

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepTopBar(step: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  30,
                  AppSpacing.screenH,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.locationTitle, style: AppText.headline),
                    const SizedBox(height: 14),
                    Text(l10n.locationBody, style: AppText.body),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  0,
                  AppSpacing.screenH,
                  AppSpacing.screenBottom,
                ),
                child: Column(
                  children: [
                    if (problem != null) ...[
                      Text(
                        problem,
                        style: AppText.body,
                        textAlign: TextAlign.center,
                      ),
                      if (canOpenSettings)
                        TextLink(
                          label: l10n.locationOpenSettings,
                          onPressed: () =>
                              ref.read(deviceLocatorProvider).openSettings(),
                        ),
                      const SizedBox(height: 18),
                    ],
                    PrimaryButton(
                      label: _locating
                          ? l10n.locationFinding
                          : l10n.locationUseMine,
                      icon: Icons.near_me_outlined,
                      loading: _locating,
                      onPressed: _useMyLocation,
                    ),
                    const SizedBox(height: 10),
                    TextLink(
                      label: l10n.locationChooseCity,
                      onPressed: _locating
                          ? null
                          : () => context.push(Routes.citySearch),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
