import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/app_scope.dart';
import '../../../models/subscription.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/money.dart';
import '../../../widgets/premium_card.dart';
import '../../../widgets/service_monogram.dart';

class ReminderCard extends StatelessWidget {
  const ReminderCard({super.key, required this.item, this.onTap});

  final Subscription item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currency = AppScope.settingsOf(context).currencyCode;
    final statusColor = switch (item.urgency) {
      UrgencyLevel.critical => AppColors.danger,
      UrgencyLevel.warning => const Color(0xFFE0A85C),
      UrgencyLevel.healthy => AppColors.accent,
    };
    final amountLabel = 'To be saved: ${Money.format(item.cost, currency)}';

    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 18, 16, 18),
      child: Row(
        children: [
          ServiceMonogram(initials: item.initials, accent: AppColors.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.statusLabel,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              amountLabel,
              textAlign: TextAlign.right,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
