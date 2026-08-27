import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../app/app_settings.dart';
import '../theme/app_colors.dart';

/// Cached tiling film-grain image, generated once at startup.
abstract final class GrainCache {
  static ui.Image? image;

  static Future<void> ensure() async {
    if (image != null) return;
    const size = 192;
    final pixels = Uint8List(size * size * 4);
    var seed = 0xA5A5A5A5;
    for (var i = 0; i < size * size; i++) {
      seed = (1103515245 * seed + 12345) & 0x7fffffff;
      final n = 70 + (seed % 110);
      final offset = i * 4;
      pixels[offset] = n;
      pixels[offset + 1] = n;
      pixels[offset + 2] = n;
      pixels[offset + 3] = 255;
    }
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      size,
      size,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    image = await completer.future;
  }
}

class GrainBackdrop extends StatelessWidget {
  const GrainBackdrop({
    super.key,
    required this.oled,
    required this.intensity,
    this.child,
  });

  final bool oled;
  final GrainIntensity intensity;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final base = oled ? AppColors.oledBackground : AppColors.background;
    final opacity = intensity == GrainIntensity.strong ? 0.17 : 0.08;

    return ColoredBox(
      color: base,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GrainOverlay(opacity: opacity),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class GrainOverlay extends StatelessWidget {
  const GrainOverlay({super.key, this.opacity = 0.05});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    final image = GrainCache.image;
    if (image == null) return const SizedBox.expand();
    return IgnorePointer(
      child: CustomPaint(
        painter: _GrainPainter(image: image, opacity: opacity),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter({required this.image, required this.opacity});

  final ui.Image image;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = ImageShader(
      image,
      TileMode.repeated,
      TileMode.repeated,
      Matrix4.identity().storage,
    );
    final paint = Paint()
      ..shader = shader
      ..color = Color.fromRGBO(255, 255, 255, opacity)
      ..blendMode = BlendMode.overlay;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.opacity != opacity;
  }
}
