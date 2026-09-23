import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show FlutterAuthClientOptions, Supabase;

import 'core/auth/auth_service.dart';
import 'core/auth/secure_session_storage.dart';
import 'core/config/app_config.dart';
import 'core/l10n/language.dart';
import 'core/purchases/purchases_service.dart';
import 'core/router/app_router.dart';
import 'core/storage/app_database.dart';
import 'core/storage/settings_store.dart';
import 'core/theme/app_theme.dart';
import 'features/account/account_sync.dart';
import 'features/alerts/alert_providers.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  useWesternDigits();
  await PurchasesService.configure();
  if (AppConfig.supabaseUrl.isNotEmpty) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
      authOptions: const FlutterAuthClientOptions(
        localStorage: SecureSessionStorage(),
        // Email codes are typed in; no magic links to catch.
        detectSessionInUri: false,
      ),
    );
  }
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
    // Signed in: settings and tasbih history follow the account.
    ref.watch(syncDriverProvider);
    // Premium follows the account: RevenueCat's user is the Supabase user.
    ref.listen(accountProvider.select((a) => a.value?.id), (_, id) {
      PurchasesService.identify(id);
    });
    return MaterialApp.router(
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
      locale: ref.watch(languageProvider).locale,
    );
  }
}
