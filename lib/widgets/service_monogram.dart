import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceMonogram extends StatelessWidget {
  const ServiceMonogram({
    super.key,
    required this.initials,
    required this.accent,
    this.size = 48,
  });

  final String initials;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Text(
        initials,
        style: GoogleFonts.outfit(
          fontSize: size * 0.33,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
    );
  }
}
