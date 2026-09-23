import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/app_config.dart';
import 'purchases_service.dart';

enum PlanKind { annual, monthly, lifetime }

/// A plan on the paywall, priced by the store in the user's currency.
class Plan {
  const Plan({
    required this.kind,
    required this.price,
    required this.priceText,
    this.package,
  });

  final PlanKind kind;
  final double price;

  /// Formatted by the store, e.g. "$35.99".
  final String priceText;

  /// The RevenueCat package to buy (null in tests).
  final Package? package;
}

enum BuyOutcome { bought, cancelled, failed }

/// Premium via App Store / Google Play through RevenueCat. An interface so
/// tests can fake it.
abstract interface class PremiumStore {
  bool get available;
  Future<bool> isPremium();
  Stream<bool> get changes;

  /// The current offering's plans, yearly first.
  Future<List<Plan>> plans();
  Future<BuyOutcome> buy(Plan plan);

  /// Restores purchases from the store account; true if premium after.
  Future<bool> restore();
}

class RevenueCatPremiumStore implements PremiumStore {
  RevenueCatPremiumStore() {
    Purchases.addCustomerInfoUpdateListener(_onInfo);
  }

  final _changes = StreamController<bool>.broadcast();

  void _onInfo(CustomerInfo info) => _changes.add(_active(info));

  static bool _active(CustomerInfo info) =>
      info.entitlements.active.containsKey(AppConfig.premiumEntitlement);

  @override
  bool get available => PurchasesService.isConfigured;

  @override
  Stream<bool> get changes => _changes.stream;

  @override
  Future<bool> isPremium() async {
    if (!available) return false;
    try {
      return _active(await Purchases.getCustomerInfo());
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<List<Plan>> plans() async {
    if (!available) return const [];
    final offering = (await Purchases.getOfferings()).current;
    if (offering == null) return const [];
    final plans = <Plan>[
      for (final p in offering.availablePackages)
        if (switch (p.packageType) {
              PackageType.annual => PlanKind.annual,
              PackageType.monthly => PlanKind.monthly,
              PackageType.lifetime => PlanKind.lifetime,
              _ => null,
            }
            case final kind?)
          Plan(
            kind: kind,
            price: p.storeProduct.price,
            priceText: p.storeProduct.priceString,
            package: p,
          ),
    ]..sort((a, b) => a.kind.index.compareTo(b.kind.index));
    return plans;
  }

  @override
  Future<BuyOutcome> buy(Plan plan) async {
    final package = plan.package;
    if (package == null) return BuyOutcome.failed;
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return _active(result.customerInfo)
          ? BuyOutcome.bought
          : BuyOutcome.failed;
    } on PlatformException catch (e) {
      return PurchasesErrorHelper.getErrorCode(e) ==
              PurchasesErrorCode.purchaseCancelledError
          ? BuyOutcome.cancelled
          : BuyOutcome.failed;
    }
  }

  @override
  Future<bool> restore() async {
    if (!available) return false;
    try {
      return _active(await Purchases.restorePurchases());
    } on PlatformException {
      return false;
    }
  }
}

/// Without a RevenueCat key: no purchases, nobody is premium.
class NoPremiumStore implements PremiumStore {
  const NoPremiumStore();
  @override
  bool get available => false;
  @override
  Future<bool> isPremium() async => false;
  @override
  Stream<bool> get changes => const Stream.empty();
  @override
  Future<List<Plan>> plans() async => const [];
  @override
  Future<BuyOutcome> buy(Plan plan) async => BuyOutcome.failed;
  @override
  Future<bool> restore() async => false;
}

final premiumStoreProvider = Provider<PremiumStore>(
  (ref) => PurchasesService.isConfigured
      ? RevenueCatPremiumStore()
      : const NoPremiumStore(),
);

/// Whether the user has Premium, kept current (purchases, restores,
/// signing in on another phone).
final premiumProvider = StreamProvider<bool>((ref) async* {
  final store = ref.watch(premiumStoreProvider);
  yield await store.isPremium();
  yield* store.changes;
});
