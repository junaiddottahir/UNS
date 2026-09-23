import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/alerts/prayer_alert_screen.dart';
import '../../features/alerts/prayer_alerts_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/location/location_providers.dart';
import '../../features/onboarding/city_search_screen.dart';
import '../../features/onboarding/intro_screen.dart';
import '../../features/onboarding/location_screen.dart';
import '../../features/onboarding/prayer_step_screen.dart';
import '../../features/onboarding/notifications_step_screen.dart';
import '../../features/onboarding/reciter_step_screen.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/prayer/method_screen.dart';
import '../../features/prayer/prayer_schedule.dart';
import '../../features/prayer/prayer_settings_screen.dart';
import '../../features/prayer/prayer_times_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/qibla/calibration_screen.dart';
import '../../features/qibla/qibla_screen.dart';
import '../../features/sources/sources_screen.dart';
import '../../features/tasbih/counter_screen.dart';
import '../../features/tasbih/history_screen.dart';
import '../../features/tasbih/tasbih_screen.dart';
import '../../l10n/app_localizations.dart';
import '../storage/settings_store.dart';
import '../widgets/coming_soon_screen.dart';
import '../widgets/tab_shell.dart';
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
        builder: (_, _) => const NotificationsStepScreen(),
      ),
      GoRoute(
        path: Routes.reciterStep,
        builder: (_, _) => const ReciterStepScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => TabShell(shell: shell),
        branches: [
          _branch(Routes.home, (_) => const HomeScreen()),
          _branch(
            Routes.shama,
            (context) =>
                ComingSoonScreen(title: AppLocalizations.of(context).tabShama),
          ),
          _branch(Routes.tasbih, (_) => const TasbihScreen()),
          _branch(Routes.profile, (_) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: Routes.qibla, builder: (_, _) => const QiblaScreen()),
      GoRoute(path: Routes.sources, builder: (_, _) => const SourcesScreen()),
      GoRoute(
        path: Routes.tasbihCounter,
        builder: (_, _) => const CounterScreen(),
      ),
      GoRoute(
        path: Routes.tasbihHistory,
        builder: (_, state) => HistoryScreen(
          justFinished: state.uri.queryParameters['done'] == '1',
        ),
      ),
      GoRoute(
        path: Routes.plans,
        builder: (context, _) => ComingSoonScreen(
          title: AppLocalizations.of(context).unsPremium,
          back: true,
        ),
      ),
      GoRoute(
        path: Routes.qiblaCalibrate,
        builder: (_, _) => const CalibrationScreen(),
      ),
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
        path: Routes.prayerAlerts,
        builder: (_, _) => const PrayerAlertsScreen(),
      ),
      GoRoute(
        path: '${Routes.prayerAlerts}/:prayer',
        redirect: (_, state) =>
            Prayer.values.asNameMap()[state.pathParameters['prayer']] == null
            ? Routes.prayerAlerts
            : null,
        builder: (_, state) => PrayerAlertScreen(
          prayer: Prayer.values.byName(state.pathParameters['prayer']!),
        ),
      ),
      GoRoute(
        path: Routes.prayerLocation,
        builder: (_, _) => const CitySearchScreen(inOnboarding: false),
      ),
    ],
  );
});

StatefulShellBranch _branch(String path, Widget Function(BuildContext) page) =>
    StatefulShellBranch(
      routes: [GoRoute(path: path, builder: (context, _) => page(context))],
    );
