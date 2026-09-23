import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/purchases/premium_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/toast.dart';
import '../../l10n/app_localizations.dart';

final plansProvider = FutureProvider.autoDispose<List<Plan>>(
  (ref) => ref.watch(premiumStoreProvider).plans(),
);

/// The paywall ("Go deeper"): yearly, monthly, lifetime from the store.
class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  PlanKind _chosen = PlanKind.annual;
  bool _busy = false;
  String? _error;

  Future<void> _buy(List<Plan> plans) async {
    final l10n = AppLocalizations.of(context);
    final plan = plans.where((p) => p.kind == _chosen).firstOrNull;
    if (plan == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final outcome = await ref.read(premiumStoreProvider).buy(plan);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (outcome) {
      case BuyOutcome.bought:
        ref.invalidate(premiumProvider);
        context.pop();
        showToast(l10n.premiumWelcome);
      case BuyOutcome.cancelled:
        break;
      case BuyOutcome.failed:
        setState(() => _error = l10n.buyFailed);
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    final ok = await ref.read(premiumStoreProvider).restore();
    if (!mounted) return;
    setState(() => _busy = false);
    ref.invalidate(premiumProvider);
    showToast(ok ? l10n.restored : l10n.nothingToRestore);
    if (ok) context.pop();
  }

  String _price(AppLocalizations l10n, Plan p) => switch (p.kind) {
    PlanKind.annual => l10n.perYear(p.priceText),
    PlanKind.monthly => l10n.perMonth(p.priceText),
    PlanKind.lifetime => l10n.once(p.priceText),
  };

  String _label(AppLocalizations l10n, PlanKind k) => switch (k) {
    PlanKind.annual => l10n.planYearly,
    PlanKind.monthly => l10n.planMonthly,
    PlanKind.lifetime => l10n.planLifetime,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final premium = ref.watch(premiumProvider).value ?? false;
    final plans = ref.watch(plansProvider);
    final list = plans.value ?? const <Plan>[];
    final monthly = list.where((p) => p.kind == PlanKind.monthly).firstOrNull;

    return Scaffold(
      body: AmbientBackground(
        fade: BackgroundFade.bottom,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 48,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: AppSpacing.screenH - 12,
                    ),
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textPrimary,
                      ),
                      tooltip: l10n.close,
                    ),
                  ),
                ),
              ),
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
                    Text(
                      premium ? l10n.youHavePremium : l10n.goDeeper,
                      style: AppText.headline,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      premium ? l10n.premiumThanks : l10n.goDeeperBody,
                      style: AppText.body,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!premium)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 44),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (plans.isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.textSubtle,
                          ),
                        )
                      else if (list.isEmpty)
                        Text(
                          l10n.plansUnavailable,
                          style: AppText.body,
                          textAlign: TextAlign.center,
                        )
                      else ...[
                        for (final p in list) ...[
                          _PlanCard(
                            label: _label(l10n, p.kind),
                            price: _price(l10n, p),
                            // Yearly vs twelve months, rounded down.
                            saving:
                                p.kind == PlanKind.annual &&
                                    monthly != null &&
                                    monthly.price > 0
                                ? ((1 - p.price / (monthly.price * 12)) * 100)
                                      .floor()
                                : null,
                            chosen: p.kind == _chosen,
                            onTap: () => setState(() => _chosen = p.kind),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (_error != null) ...[
                          Text(
                            _error!,
                            style: AppText.body,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                        ],
                        PrimaryButton(
                          label: l10n.continueLabel,
                          loading: _busy,
                          onPressed: () => _buy(list),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.noAdsRestore.toUpperCase(),
                            style: AppText.label,
                          ),
                          Text(' · ', style: AppText.label),
                          TextButton(
                            onPressed: _busy ? null : _restore,
                            child: Text(
                              l10n.restore.toUpperCase(),
                              style: AppText.label,
                            ),
                          ),
                        ],
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

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.label,
    required this.price,
    required this.saving,
    required this.chosen,
    required this.onTap,
  });

  final String label;
  final String price;
  final int? saving;
  final bool chosen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      selected: chosen,
      button: true,
      child: Material(
        color: AppColors.glassFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(
            color: chosen ? AppColors.textPrimary : AppColors.glassEdge,
            width: chosen ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 17,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (saving case final s? when s > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          l10n.savePercent(s).toUpperCase(),
                          style: AppText.label.copyWith(
                            color: AppColors.accentPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Opacity(
                  opacity: chosen ? 1 : 0.7,
                  child: Text(
                    price,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
