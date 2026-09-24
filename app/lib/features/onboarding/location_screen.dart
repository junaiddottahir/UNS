import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../location/device_locator.dart';
import '../location/location_problem_text.dart';
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

    final result = await ref.read(userLocationProvider.notifier).useDevice();
    if (!mounted) return;

    setState(() {
      _locating = false;
      _problem = result is DeviceLocationFound ? null : result;
    });
    if (result is DeviceLocationFound) context.push(Routes.prayerStep);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final problem = locationProblemText(l10n, _problem);
    final canOpenSettings = needsSettings(_problem);

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
                    // The choice sits above the button, so the button is
                    // placed as on every onboarding screen.
                    TextLink(
                      label: l10n.locationChooseCity,
                      onPressed: _locating
                          ? null
                          : () => context.push(Routes.citySearch),
                    ),
                    const SizedBox(height: 10),
                    PrimaryButton(
                      label: _locating
                          ? l10n.locationFinding
                          : l10n.locationUseMine,
                      icon: Icons.near_me_outlined,
                      loading: _locating,
                      onPressed: _useMyLocation,
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
