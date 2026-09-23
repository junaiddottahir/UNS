import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../location/city.dart';
import '../location/location_providers.dart';

/// Manual city fallback for onboarding step 1.
class CitySearchScreen extends ConsumerStatefulWidget {
  const CitySearchScreen({super.key});

  @override
  ConsumerState<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends ConsumerState<CitySearchScreen> {
  String _query = '';

  void _choose(City city) {
    ref.read(userLocationProvider.notifier).set(UserLocation.fromCity(city));
    context.push(Routes.prayerStep);
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
                    Text(l10n.citySearchTitle, style: AppText.headline),
                    const SizedBox(height: 28),
                    TextField(
                      autofocus: true,
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
