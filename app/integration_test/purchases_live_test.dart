import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uns/core/purchases/premium_store.dart';
import 'package:uns/core/purchases/purchases_service.dart';

/// Fetches the real RevenueCat offering (Test Store key from dev.json):
///   flutter test integration_test/purchases_live_test.dart -d SIMULATOR_ID \
///     --dart-define-from-file=config/dev.json
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the paywall gets yearly, monthly and lifetime with prices', (
    tester,
  ) async {
    await PurchasesService.configure();
    expect(PurchasesService.isConfigured, isTrue);
    final store = RevenueCatPremiumStore();
    final plans = await store.plans();
    expect(plans.map((p) => p.kind), [
      PlanKind.annual,
      PlanKind.monthly,
      PlanKind.lifetime,
    ]);
    for (final p in plans) {
      expect(p.price, greaterThan(0));
      expect(p.priceText, isNotEmpty);
    }
    expect(await store.isPremium(), isFalse);
  });
}
