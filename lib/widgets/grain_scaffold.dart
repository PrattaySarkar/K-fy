import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../theme/app_colors.dart';
import 'film_grain.dart';

class GrainScaffold extends StatelessWidget {
  const GrainScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.settingsOf(context);
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            GrainBackdrop(
              oled: settings.oledTrueBlack,
              intensity: settings.grainIntensity,
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: appBar,
              body: body,
              bottomNavigationBar: bottomNavigationBar == null
                  ? null
                  : ColoredBox(
                      color: (settings.oledTrueBlack
                              ? AppColors.oledBackground
                              : AppColors.background)
                          .withValues(alpha: 0.92),
                      child: bottomNavigationBar,
                    ),
            ),
          ],
        );
      },
    );
  }
}
