import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/app_scope.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/money.dart';
import '../../../widgets/premium_card.dart';

class SavingsHeroCard extends StatelessWidget {
  const SavingsHeroCard({super.key, required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final currency = AppScope.settingsOf(context).currencyCode;
    final formatted = Money.format(amount, currency);

    return PremiumCard(
      minHeight: 276,
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Saved till date',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 22),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatted,
              style: GoogleFonts.outfit(
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
