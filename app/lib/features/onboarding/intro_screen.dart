import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../l10n/app_localizations.dart';

/// Three swipeable intro slides with progress bars and Skip.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _images = [
    'assets/images/bg_intro_1.jpg',
    'assets/images/bg_intro_2.jpg',
    'assets/images/bg_intro_3.jpg',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toLocation() => context.push(Routes.location);

  void _next() {
    if (_page == _images.length - 1) {
      _toLocation();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: const Cubic(0.2, 0.8, 0.2, 1),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = [
      (l10n.intro1Title, l10n.intro1Body),
      (l10n.intro2Title, l10n.intro2Body),
      (l10n.intro3Title, l10n.intro3Body),
    ];
    final isLast = _page == slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => AmbientBackground(
              image: _images[i],
              fade: BackgroundFade.bottom,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.screenH,
                    0,
                    AppSpacing.screenH + 84,
                    AppSpacing.screenBottom,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(slides[i].$1, style: AppText.title),
                      const SizedBox(height: 12),
                      Text(slides[i].$2, style: AppText.body),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: AppSpacing.screenH,
                      end: AppSpacing.screenH - 12,
                    ),
                    child: Row(
                      children: [
                        for (var i = 0; i < slides.length; i++) ...[
                          if (i > 0) const SizedBox(width: 6),
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 2,
                              color: i <= _page
                                  ? AppColors.textPrimary
                                  : AppColors.track,
                            ),
                          ),
                        ],
                        const SizedBox(width: 16),
                        Opacity(
                          opacity: isLast ? 0 : 1,
                          child: TextLink(
                            label: l10n.introSkip,
                            onPressed: isLast ? null : _toLocation,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: AppSpacing.screenH,
                      bottom: AppSpacing.screenBottom,
                    ),
                    child: OrbButton(
                      onPressed: _next,
                      semanticLabel: l10n.introNext,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
