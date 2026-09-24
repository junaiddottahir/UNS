import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The app's own icons (assets/icons), used in the tab bar and wherever
/// the same feature is linked.
abstract final class AppIcons {
  static const home = 'assets/icons/tab_home.svg';
  static const shama = 'assets/icons/tab_shama.svg';
  static const tasbih = 'assets/icons/tab_tasbih.svg';
  static const profile = 'assets/icons/tab_profile.svg';
}

/// An SVG icon that takes its size and colour from the [IconTheme], like
/// [Icon] does, unless given.
class SvgIcon extends StatelessWidget {
  const SvgIcon(this.asset, {super.key, this.size, this.color});

  final String asset;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final side = size ?? theme.size ?? 24;
    final tint = color ?? theme.color;
    return SvgPicture.asset(
      asset,
      width: side,
      height: side,
      colorFilter: tint == null
          ? null
          : ColorFilter.mode(tint, BlendMode.srcIn),
    );
  }
}
