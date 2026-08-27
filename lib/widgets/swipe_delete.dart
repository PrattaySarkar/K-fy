import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SwipeDelete extends StatelessWidget {
  const SwipeDelete({
    super.key,
    required this.id,
    required this.onDelete,
    required this.child,
    this.label = 'this subscription',
  });

  final String id;
  final VoidCallback onDelete;
  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: AppColors.dangerSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Delete subscription?'),
          content: Text('Remove $label from K.fy?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: child,
    );
  }
}
