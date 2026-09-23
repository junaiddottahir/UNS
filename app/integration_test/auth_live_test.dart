import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uns/core/auth/auth_service.dart';
import 'package:uns/core/auth/secure_session_storage.dart';
import 'package:uns/core/config/app_config.dart';

/// Reaches the real Supabase Auth for project "Uns" (needs the dev
/// dart-defines and a network):
///   flutter test integration_test/auth_live_test.dart -d SIMULATOR_ID \
///     --dart-define-from-file=config/dev.json
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Supabase Auth answers; a wrong password is reported', (
    tester,
  ) async {
    expect(AppConfig.supabaseUrl, isNotEmpty);
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
      authOptions: const FlutterAuthClientOptions(
        localStorage: SecureSessionStorage(),
        detectSessionInUri: false,
      ),
    );
    final auth = SupabaseAuthService(Supabase.instance.client.auth);
    expect(auth.current, isNull);
    await expectLater(
      auth.signIn('nobody@uns.invalid', 'not the password'),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.problem,
          'problem',
          AuthProblem.wrongPassword,
        ),
      ),
    );
  });
}
