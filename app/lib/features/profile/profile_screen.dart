import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../l10n/app_localizations.dart';

/// Profile tab. Account, language, premium and privacy arrive with their
/// units; for now it reaches settings and sources.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  22,
                  AppSpacing.screenH,
                  0,
                ),
                child: Text(l10n.tabProfile, style: AppText.title2),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 26, 18, 124),
                child: GlassCard(
                  child: Column(
                    children: [
                      GlassRow(
                        leading: Icons.tune,
                        label: Text(l10n.prayerSettingsTitle),
                        trailing: Icons.chevron_right,
                        onTap: () => context.push(Routes.prayerSettings),
                      ),
                      GlassRow(
                        leading: Icons.menu_book_outlined,
                        label: Text(l10n.ourSources),
                        trailing: Icons.chevron_right,
                        divider: false,
                        onTap: () => context.push(Routes.sources),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
