import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_colors.dart';

class PillTabBar extends StatelessWidget {
  const PillTabBar({super.key});

  static const tabs = ['Reminders', 'Subscriptions', 'History'];

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(width: 3, color: AppColors.accent),
        insets: EdgeInsets.symmetric(horizontal: 12),
      ),
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: AppColors.border,
      labelColor: AppColors.textPrimary,
      unselectedLabelColor: AppColors.textMuted,
      labelStyle: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      tabs: [for (final label in tabs) Tab(text: label)],
    );
  }
}
