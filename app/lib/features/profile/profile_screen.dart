import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_service.dart';
import '../../core/l10n/language.dart';
import '../../core/purchases/premium_store.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/toast.dart';
import '../../l10n/app_localizations.dart';
import '../journal/journal_providers.dart';
import '../reciter/reciter.dart';
import '../reciter/reciter_labels.dart';
import 'language_screen.dart';

/// Profile (prototype): the account card, then journal, premium, prayer,
/// alerts, recitation, privacy and sources.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(journalProvider).value?.length ?? 0;
    final auth = ref.watch(authServiceProvider);
    final account = ref.watch(accountProvider).value;
    final reciter = ref.watch(reciterProvider);
    final premium = ref.watch(premiumProvider).value ?? false;

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.tabProfile.toUpperCase(),
                      style: AppText.label,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 124),
                child: Column(
                  children: [
                    if (auth.available) ...[
                      _AccountCard(
                        title: account == null
                            ? l10n.saveYourJourney
                            : l10n.journeySaved,
                        subtitle: account == null
                            ? l10n.syncSettings
                            : l10n.signedInWith(account.email ?? ''),
                        signedIn: account != null,
                        onTap: () => context.push(
                          account == null ? Routes.accountSave : Routes.account,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    GlassCard(
                      child: Column(
                        children: [
                          GlassRow(
                            leading: Icons.edit_note,
                            label: Text(l10n.journal),
                            value: l10n.journalCount(entries),
                            trailing: Icons.chevron_right,
                            onTap: () => context.push(Routes.journal),
                          ),
                          GlassRow(
                            leading: Icons.auto_awesome_outlined,
                            label: Text(l10n.premium),
                            value: premium ? l10n.premiumActive : null,
                            trailing: Icons.chevron_right,
                            onTap: () => context.push(Routes.plans),
                          ),
                          GlassRow(
                            leading: Icons.schedule,
                            label: Text(l10n.prayer),
                            trailing: Icons.chevron_right,
                            onTap: () => context.push(Routes.prayerSettings),
                          ),
                          GlassRow(
                            leading: Icons.notifications_none,
                            label: Text(l10n.alerts),
                            trailing: Icons.chevron_right,
                            onTap: () => context.push(Routes.prayerAlerts),
                          ),
                          GlassRow(
                            leading: Icons.graphic_eq,
                            label: Text(l10n.recitation),
                            value: l10n.reciterName(reciter),
                            trailing: Icons.chevron_right,
                            onTap: () => context.push(Routes.reciterSettings),
                          ),
                          GlassRow(
                            leading: Icons.translate,
                            label: Text(l10n.language),
                            value: l10n.languageName(
                              ref.watch(languageProvider),
                            ),
                            trailing: Icons.chevron_right,
                            divider: false,
                            onTap: () => context.push(Routes.language),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassCard(
                      child: Column(
                        children: [
                          GlassRow(
                            leading: Icons.shield_outlined,
                            label: Text(l10n.privacy),
                            trailing: Icons.chevron_right,
                            onTap: () => context.push(Routes.privacy),
                          ),
                          GlassRow(
                            leading: Icons.menu_book_outlined,
                            label: Text(l10n.ourSources),
                            trailing: Icons.chevron_right,
                            onTap: () => context.push(Routes.sources),
                          ),
                          GlassRow(
                            leading: Icons.restore,
                            label: Text(l10n.restorePurchases),
                            divider: false,
                            onTap: () async {
                              final ok = await ref
                                  .read(premiumStoreProvider)
                                  .restore();
                              ref.invalidate(premiumProvider);
                              showToast(
                                ok ? l10n.restored : l10n.nothingToRestore,
                              );
                            },
                          ),
                        ],
                      ),
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

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.title,
    required this.subtitle,
    required this.signedIn,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool signedIn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(2, 14, 0, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: AppText.body.copyWith(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.ctaBackground,
                ),
                child: Icon(
                  signedIn ? Icons.check : Icons.arrow_forward,
                  color: AppColors.ctaForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
