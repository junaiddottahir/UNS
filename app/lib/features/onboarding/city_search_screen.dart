import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../location/city.dart';
import '../location/device_locator.dart';
import '../location/location_problem_text.dart';
import '../location/location_providers.dart';

/// City search: the manual fallback in onboarding step 1, and the location
/// picker in prayer settings, where it also offers the current location.
class CitySearchScreen extends ConsumerStatefulWidget {
  const CitySearchScreen({super.key, this.inOnboarding = true});

  /// In onboarding a pick continues to step 2; in settings it goes back.
  final bool inOnboarding;

  @override
  ConsumerState<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends ConsumerState<CitySearchScreen> {
  String _query = '';
  bool _locating = false;
  DeviceLocationResult? _problem;

  void _choose(City city) {
    ref.read(userLocationProvider.notifier).set(UserLocation.fromCity(city));
    _done();
  }

  void _done() {
    if (widget.inOnboarding) {
      context.push(Routes.prayerStep);
    } else {
      context.pop();
    }
  }

  Future<void> _useCurrentLocation() async {
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
    if (result is DeviceLocationFound) _done();
  }

  Widget _currentLocationRow(AppLocalizations l10n) {
    final usingDevice =
        ref.watch(userLocationProvider)?.source == LocationSource.device;
    final problem = locationProblemText(l10n, _problem);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenH,
          ),
          leading: const Icon(
            Icons.near_me_outlined,
            color: AppColors.textMuted,
          ),
          title: Text(
            _locating ? l10n.locationFinding : l10n.currentLocation,
            style: const TextStyle(fontSize: 17),
          ),
          trailing: usingDevice && !_locating
              ? const Icon(Icons.check, color: AppColors.textPrimary)
              : null,
          onTap: _locating ? null : _useCurrentLocation,
        ),
        if (problem != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            child: Text(problem, style: AppText.body),
          ),
        if (needsSettings(_problem))
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH - 12,
            ),
            child: TextLink(
              label: l10n.locationOpenSettings,
              onPressed: () => ref.read(deviceLocatorProvider).openSettings(),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(cityRepositoryProvider);

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.inOnboarding)
                const StepTopBar(step: 1)
              else
                const BackTopBar(),
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
                    widget.inOnboarding
                        ? Text(l10n.citySearchTitle, style: AppText.headline)
                        : Text(l10n.locationLabel, style: AppText.title2),
                    const SizedBox(height: 28),
                    TextField(
                      autofocus: widget.inOnboarding,
                      style: AppText.input,
                      textInputAction: TextInputAction.search,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: l10n.citySearchHint,
                        hintStyle: AppText.input.copyWith(
                          color: AppColors.textFaint,
                        ),
                        contentPadding: const EdgeInsets.only(bottom: 14),
                        isDense: true,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.textSubtle),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: repo.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.textSubtle,
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text(l10n.locationFailed, style: AppText.body),
                  ),
                  data: (cities) {
                    final results = cities.search(_query);
                    if (!widget.inOnboarding && _query.trim().isEmpty) {
                      return Material(
                        type: MaterialType.transparency,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          children: [_currentLocationRow(l10n)],
                        ),
                      );
                    }
                    if (results.isEmpty && _query.trim().length >= 2) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.screenH),
                        child: Text(
                          l10n.citySearchEmpty(_query.trim()),
                          style: AppText.body,
                        ),
                      );
                    }
                    return Material(
                      type: MaterialType.transparency,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: results.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          indent: AppSpacing.screenH,
                          endIndent: AppSpacing.screenH,
                          color: AppColors.borderDefault,
                        ),
                        itemBuilder: (context, i) {
                          final city = results[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenH,
                            ),
                            title: Text(
                              city.name,
                              style: const TextStyle(fontSize: 17),
                            ),
                            subtitle: Text(city.detail, style: AppText.body),
                            onTap: () => _choose(city),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
