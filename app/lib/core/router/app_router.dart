import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/home_screen.dart';
import '../../features/location/location_providers.dart';
import '../../features/onboarding/city_search_screen.dart';
import '../../features/onboarding/intro_screen.dart';
import '../../features/onboarding/location_screen.dart';
import '../../features/onboarding/prayer_step_screen.dart';
import '../../features/onboarding/step_placeholder_screen.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/prayer/method_screen.dart';
import '../../features/prayer/prayer_settings_screen.dart';
import '../../features/prayer/prayer_times_screen.dart';
import '../../l10n/app_localizations.dart';
import '../storage/settings_store.dart';
import 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Returning users go straight home; onboarding shows until it's finished.
  final onboarded =
      ref
          .read(settingsStoreProvider)
          .readBool(SettingKeys.onboardingComplete) &&
      ref.read(userLocationProvider) != null;
  return GoRouter(
    initialLocation: onboarded ? Routes.home : Routes.welcome,
    routes: [
      GoRoute(path: Routes.welcome, builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: Routes.intro, builder: (_, _) => const IntroScreen()),
      GoRoute(path: Routes.location, builder: (_, _) => const LocationScreen()),
      GoRoute(
        path: Routes.citySearch,
        builder: (_, _) => const CitySearchScreen(),
      ),
      GoRoute(
        path: Routes.prayerStep,
        builder: (_, _) => const PrayerStepScreen(),
      ),
      GoRoute(
        path: Routes.notificationsStep,
        builder: (context, _) {
          final l10n = AppLocalizations.of(context);
          return StepPlaceholderScreen(
            step: 3,
            title: l10n.notificationsStepTitle,
            body: l10n.notificationsStepBody,
            actionLabel: l10n.continueLabel,
            onAction: () => context.push(Routes.reciterStep),
          );
        },
      ),
      GoRoute(
        path: Routes.reciterStep,
        builder: (context, _) {
          final l10n = AppLocalizations.of(context);
          return StepPlaceholderScreen(
            step: 4,
            title: l10n.reciterStepTitle,
            body: l10n.reciterStepBody,
            actionLabel: l10n.finish,
            onAction: () {
              ref
                  .read(settingsStoreProvider)
                  .writeBool(SettingKeys.onboardingComplete, true);
              context.go(Routes.home);
            },
          );
        },
      ),
      GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: Routes.prayerTimes,
        builder: (_, _) => const PrayerTimesScreen(),
      ),
      GoRoute(
        path: Routes.prayerSettings,
        builder: (_, _) => const PrayerSettingsScreen(),
      ),
      GoRoute(
        path: Routes.prayerMethod,
        builder: (_, _) => const MethodScreen(),
      ),
      GoRoute(
        path: Routes.prayerLocation,
        builder: (_, _) => const CitySearchScreen(inOnboarding: false),
      ),
    ],
  );
});
