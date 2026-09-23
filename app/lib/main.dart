import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/purchases/purchases_service.dart';
import 'core/router/app_router.dart';
import 'core/storage/app_database.dart';
import 'core/storage/settings_store.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/toast.dart';
import 'features/alerts/alert_providers.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PurchasesService.configure();
  final db = await AppDatabase.open();
  final settings = await SettingsStore.load(db);
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        settingsStoreProvider.overrideWithValue(settings),
      ],
      child: const UnsApp(),
    ),
  );
}

class UnsApp extends ConsumerStatefulWidget {
  const UnsApp({super.key});

  @override
  ConsumerState<UnsApp> createState() => _UnsAppState();
}

class _UnsAppState extends ConsumerState<UnsApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Notifications may have been turned on in Settings meanwhile.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(permissionCheckProvider.notifier).recheck(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keeps scheduled prayer alerts current from launch.
    ref.watch(alertSyncProvider);
    return MaterialApp.router(
      scaffoldMessengerKey: rootMessengerKey,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: ref.watch(appRouterProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
