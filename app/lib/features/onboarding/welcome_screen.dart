import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: AmbientBackground(
        image: 'assets/images/bg_welcome.jpg',
        fade: BackgroundFade.bottom,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: height * 0.22,
                left: 0,
                right: 0,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 96,
                    height: 96,
                    semanticsLabel: l10n.appTitle,
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.screenH,
                right: AppSpacing.screenH,
                bottom: AppSpacing.screenBottom,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomeGreeting.toUpperCase(),
                      style: AppText.label,
                    ),
                    const SizedBox(height: 14),
                    Text(l10n.welcomeHeadline, style: AppText.headline),
                    const SizedBox(height: 36),
                    PrimaryButton(
                      label: l10n.welcomeBegin,
                      onPressed: () => context.push(Routes.intro),
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
