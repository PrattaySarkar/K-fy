import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/app_scope.dart';
import '../../../models/subscription.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/swipe_delete.dart';
import 'edit_subscription_sheet.dart';
import 'subscription_card.dart';

class SubscriptionsTab extends StatelessWidget {
  const SubscriptionsTab({super.key, required this.items});

  final List<Subscription> items;

  Future<void> _edit(BuildContext context, Subscription item) async {
    final updated = await showEditSubscriptionSheet(
      context: context,
      subscription: item,
    );
    if (updated == null || !context.mounted) return;
    await AppScope.subscriptionsOf(context).upsert(updated);
  }

  Future<void> _cancel(BuildContext context, Subscription item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            'Cancel ${item.name}?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'This marks the subscription as cancelled in K.fy. '
            'You still need to cancel it with the provider.',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Cancel subscription'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    await AppScope.subscriptionsOf(context).upsert(
      item.copyWith(isHistorical: true, isActive: false),
    );
    await AppScope.settingsOf(context).addToSavings(item.cost);
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No subscriptions yet',
          style: GoogleFonts.outfit(color: AppColors.textMuted),
        ),
      );
    }

    final repo = AppScope.subscriptionsOf(context);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 22),
      itemBuilder: (context, index) {
        final item = items[index];
        return SwipeDelete(
          id: item.id,
          label: item.name,
          onDelete: () => repo.delete(item.id),
          child: SubscriptionCard(
            subscription: item,
            onActiveChanged: (active) {
              repo.upsert(item.copyWith(isActive: active));
            },
            onEdit: () => _edit(context, item),
            onCancel: () => _cancel(context, item),
          ),
        );
      },
    );
  }
}
