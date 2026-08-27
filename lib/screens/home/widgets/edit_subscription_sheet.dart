import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/app_scope.dart';
import '../../../models/subscription.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/money.dart';

Future<Subscription?> showEditSubscriptionSheet({
  required BuildContext context,
  required Subscription subscription,
}) {
  return showModalBottomSheet<Subscription>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _EditSubscriptionSheet(subscription: subscription),
  );
}

class _EditSubscriptionSheet extends StatefulWidget {
  const _EditSubscriptionSheet({required this.subscription});

  final Subscription subscription;

  @override
  State<_EditSubscriptionSheet> createState() => _EditSubscriptionSheetState();
}

class _EditSubscriptionSheetState extends State<_EditSubscriptionSheet> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  late BillingCycle _cycle;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.subscription.name);
    _price = TextEditingController(
      text: widget.subscription.cost.toString(),
    );
    _cycle = widget.subscription.cycle;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  void _save() {
    final parsed = double.tryParse(_price.text.trim());
    if (parsed == null || _name.text.trim().isEmpty) return;
    Navigator.of(context).pop(
      widget.subscription.copyWith(
        name: _name.text.trim(),
        cycle: _cycle,
        cost: parsed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = AppScope.settingsOf(context).currencyCode;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Edit details',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            style: GoogleFonts.outfit(),
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: GoogleFonts.outfit(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.outfit(),
            decoration: InputDecoration(
              labelText: 'Cost',
              prefixText: '${Money.symbol(currency)} ',
              labelStyle: GoogleFonts.outfit(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<BillingCycle>(
            initialValue: _cycle,
            dropdownColor: AppColors.surfaceElevated,
            decoration: InputDecoration(
              labelText: 'Billing cycle',
              labelStyle: GoogleFonts.outfit(color: AppColors.textMuted),
            ),
            items: [
              for (final cycle in BillingCycle.values)
                DropdownMenuItem(
                  value: cycle,
                  child: Text(cycle.label, style: GoogleFonts.outfit()),
                ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _cycle = value);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                ),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
