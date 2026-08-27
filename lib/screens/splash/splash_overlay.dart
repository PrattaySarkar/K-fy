import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_settings.dart';
import '../../theme/app_colors.dart';
import '../../widgets/film_grain.dart';
import '../../widgets/kfy_logo.dart';

/// Hold duration is 10s for visual QA; shorten [hold] later.
class SplashOverlay extends StatefulWidget {
  const SplashOverlay({
    super.key,
    required this.onFinished,
    this.hold = const Duration(seconds: 10),
  });

  final VoidCallback onFinished;
  final Duration hold;

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slide;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _slide = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _offset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.08),
    ).animate(CurvedAnimation(parent: _slide, curve: Curves.easeInCubic));
    Future<void>.delayed(widget.hold, _playExit);
  }

  Future<void> _playExit() async {
    if (!mounted) return;
    await _slide.forward();
    if (mounted) widget.onFinished();
  }

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSettings? settings;
    try {
      settings = AppScope.settingsOf(context);
    } catch (_) {}

    final body = GrainBackdrop(
      oled: settings?.oledTrueBlack ?? false,
      intensity: settings?.grainIntensity ?? GrainIntensity.subtle,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const KfyLogo(size: 84),
          const Padding(
            padding: EdgeInsets.only(top: 168),
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );

    return SlideTransition(
      position: _offset,
      child: Material(
        color: AppColors.background,
        child: body,
      ),
    );
  }
}
