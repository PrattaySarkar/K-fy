import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'film_grain.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.onTap,
    this.minHeight,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final VoidCallback? onTap;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.settingsOf(context);
    final r = radius ?? AppTheme.radiusCard;
    final borderRadius = BorderRadius.circular(r);

    final panel = ClipRRect(
      borderRadius: borderRadius,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight ?? 0),
        child: Stack(
          children: [
            const Positioned.fill(
              child: ColoredBox(color: AppColors.card),
            ),
            Positioned.fill(
              child: GrainOverlay(opacity: settings.grainOpacity * 0.62),
            ),
            padding == null
                ? child
                : Padding(padding: padding!, child: child),
          ],
        ),
      ),
    );

    final framed = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: panel,
    );

    if (onTap == null) return framed;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: framed,
      ),
    );
  }
}
