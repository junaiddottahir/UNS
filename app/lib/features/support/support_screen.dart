import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../l10n/app_localizations.dart';

/// Places a phone call. An interface so tests can fake it.
abstract interface class Dialer {
  /// False when the phone can't start the call (e.g. a simulator).
  Future<bool> call(String number);
}

class UrlDialer implements Dialer {
  const UrlDialer();

  @override
  Future<bool> call(String number) async {
    try {
      return await launchUrl(Uri(scheme: 'tel', path: number));
    } on Exception {
      return false;
    }
  }
}

final dialerProvider = Provider<Dialer>((ref) => const UrlDialer());

/// Support resources, shown instead of a session whenever a check finds
/// risk. The helpline comes from app config, never hardcoded here.
class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  bool _callFailed = false;

  Future<void> _call() async {
    final ok = await ref.read(dialerProvider).call(AppConfig.helplineNumber);
    if (mounted) setState(() => _callFailed = !ok);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const number = AppConfig.helplineNumber;
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              78,
              AppSpacing.screenH,
              AppSpacing.screenBottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.supportTitle, style: AppText.headline),
                const SizedBox(height: 14),
                Text(l10n.supportBody, style: AppText.body),
                const Spacer(),
                if (_callFailed) ...[
                  Text(
                    l10n.callFailed(number),
                    style: AppText.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                ],
                SizedBox(
                  height: 58,
                  child: OutlinedButton.icon(
                    onPressed: _call,
                    icon: const Icon(Icons.phone_outlined, size: 18),
                    label: Text(l10n.emergencyCall(number)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: AppColors.glassFill,
                      side: const BorderSide(color: AppColors.glassEdge),
                      shape: const StadiumBorder(),
                      textStyle: AppText.button,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextLink(
                  label: l10n.imSafe,
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(Routes.home),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
