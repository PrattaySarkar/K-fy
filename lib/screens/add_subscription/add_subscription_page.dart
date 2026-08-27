import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../app/app_scope.dart';
import '../../models/add_subscription_draft.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/money.dart';
import '../../widgets/film_grain.dart';

/// Opens the add flow as a near-full-screen modal sheet.
Future<AddSubscriptionDraft?> showAddSubscriptionSheet(BuildContext context) {
  return showModalBottomSheet<AddSubscriptionDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const AddSubscriptionPage(presentedAsSheet: true),
  );
}

/// Dedicated entry screen for adding a subscription or free trial.
///
/// Use [showAddSubscriptionSheet] for a modal, or push this widget as a route:
/// `Navigator.push(context, AddSubscriptionPage.route())`.
class AddSubscriptionPage extends StatefulWidget {
  const AddSubscriptionPage({super.key, this.presentedAsSheet = false});

  final bool presentedAsSheet;

  static Route<AddSubscriptionDraft> route() {
    return MaterialPageRoute<AddSubscriptionDraft>(
      builder: (_) => const AddSubscriptionPage(),
    );
  }

  @override
  State<AddSubscriptionPage> createState() => _AddSubscriptionPageState();
}

class _AddSubscriptionPageState extends State<AddSubscriptionPage> {
  final _name = TextEditingController();
  final _cost = TextEditingController();
  final _nameFocus = FocusNode();
  final _costFocus = FocusNode();

  BillingPeriod _period = BillingPeriod.monthly;
  DateTime _date = DateTime.now().add(const Duration(days: 14));
  bool _remindersEnabled = true;
  ReminderLeadTime _remindBefore = ReminderLeadTime.twoDays;
  NotificationIntensity _intensity = NotificationIntensity.standard;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _cost.dispose();
    _nameFocus.dispose();
    _costFocus.dispose();
    super.dispose();
  }

  void _applyRiskIntensity() {
    setState(() {
      _intensity = NotificationIntensityLabel.fromTrialRisk(_date);
      _error = null;
    });
  }

  Future<void> _pickDate() async {
    const accent = AppColors.accent;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(now) ? now : _date,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 6),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: accent,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _error = null;
    });
  }

  void _save() {
    final name = _name.text.trim();
    final cost = double.tryParse(_cost.text.trim());
    if (name.isEmpty) {
      setState(() => _error = 'Enter a service name.');
      _nameFocus.requestFocus();
      return;
    }
    if (cost == null || cost < 0) {
      setState(() => _error = 'Enter a valid cost to be charged.');
      _costFocus.requestFocus();
      return;
    }

    final currency = AppScope.settingsOf(context).currencyCode;
    Navigator.of(context).pop(
      AddSubscriptionDraft(
        name: name,
        period: _period,
        cost: cost,
        expiryOrRenewal: _date,
        remindersEnabled: _remindersEnabled,
        remindBefore: _remindBefore,
        intensity: _intensity,
        currency: currency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.accent;
    final currency = AppScope.settingsOf(context).currencyCode;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final dateLabel = DateFormat.yMMMMd().format(_date);

    final body = Column(
      children: [
        _Header(
          presentedAsSheet: widget.presentedAsSheet,
          onClose: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Text(
                'Service',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              _FieldCard(
                child: TextField(
                  controller: _name,
                  focusNode: _nameFocus,
                  textInputAction: TextInputAction.next,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  decoration: _fieldDecoration(
                    hint: 'Enter service name, e.g., Netflix, Cursor',
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Billing period',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              _FieldCard(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<BillingPeriod>(
                    value: _period,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    items: [
                      for (final period in BillingPeriod.values)
                        DropdownMenuItem(
                          value: period,
                          child: Text(period.label),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _period = value;
                        _error = null;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Cost to be charged',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              _FieldCard(
                child: TextField(
                  controller: _cost,
                  focusNode: _costFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  decoration: _fieldDecoration(hint: '0.00').copyWith(
                    prefixText: '${Money.symbol(currency)}  ',
                    prefixStyle: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _period.dateFieldLabel,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              _FieldCard(
                onTap: _pickDate,
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 20,
                      color: accent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dateLabel,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _NotificationSection(
                enabled: _remindersEnabled,
                remindBefore: _remindBefore,
                intensity: _intensity,
                period: _period,
                onEnabledChanged: (value) {
                  setState(() => _remindersEnabled = value);
                },
                onLeadTimeChanged: (value) {
                  setState(() => _remindBefore = value);
                },
                onIntensityChanged: (value) {
                  setState(() => _intensity = value);
                },
                onRiskHintTap: _applyRiskIntensity,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + bottomInset),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  ),
                ),
                child: Text(
                  'Save Subscription',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    final settings = AppScope.settingsOf(context);
    final grain = GrainBackdrop(
      oled: settings.oledTrueBlack,
      intensity: settings.grainIntensity,
      child: body,
    );

    if (widget.presentedAsSheet) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.94,
        child: Material(
          color: AppColors.background,
          child: grain,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: grain),
    );
  }

  InputDecoration _fieldDecoration({required String hint}) {
    return InputDecoration(
      isDense: true,
      border: InputBorder.none,
      hintText: hint,
      hintStyle: GoogleFonts.outfit(
        fontSize: 15,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.presentedAsSheet,
    required this.onClose,
  });

  final bool presentedAsSheet;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, presentedAsSheet ? 10 : 8, 8, 8),
      child: Column(
        children: [
          if (presentedAsSheet)
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Add New Subscription',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                tooltip: 'Close',
                icon: const Icon(Icons.close_rounded),
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      constraints: const BoxConstraints(minHeight: 56),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: AppColors.accent.withValues(alpha: 0.12),
        child: content,
      ),
    );
  }
}

class _NotificationSection extends StatelessWidget {
  const _NotificationSection({
    required this.enabled,
    required this.remindBefore,
    required this.intensity,
    required this.period,
    required this.onEnabledChanged,
    required this.onLeadTimeChanged,
    required this.onIntensityChanged,
    required this.onRiskHintTap,
  });

  final bool enabled;
  final ReminderLeadTime remindBefore;
  final NotificationIntensity intensity;
  final BillingPeriod period;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<ReminderLeadTime> onLeadTimeChanged;
  final ValueChanged<NotificationIntensity> onIntensityChanged;
  final VoidCallback onRiskHintTap;

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.accent;
    final reminderLabel = period == BillingPeriod.freeTrial
        ? 'Remind me ${remindBefore.label.toLowerCase()} trial ends'
        : 'Remind me ${remindBefore.label.toLowerCase()} renewal';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Notifications & urgency',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch.adaptive(
                value: enabled,
                onChanged: onEnabledChanged,
                activeThumbColor: accent,
                activeTrackColor: accent.withValues(alpha: 0.45),
              ),
            ],
          ),
          Text(
            reminderLabel,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in ReminderLeadTime.values)
                _SelectChip(
                  label: option.label,
                  selected: enabled && remindBefore == option,
                  onTap: enabled ? () => onLeadTimeChanged(option) : null,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Intensity',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final option in NotificationIntensity.values) ...[
                if (option != NotificationIntensity.values.first)
                  const SizedBox(width: 8),
                Expanded(
                  child: _SelectChip(
                    label: option.label,
                    selected: enabled && intensity == option,
                    onTap: enabled ? () => onIntensityChanged(option) : null,
                    expanded: true,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: enabled ? onRiskHintTap : null,
            child: Text(
              'Click this information to determine notification intensity based on trial risk. ${intensity.hint}.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                height: 1.4,
                color: enabled ? accent.withValues(alpha: 0.9) : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.expanded = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.accent;
    final enabled = onTap != null;

    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      alignment: expanded ? Alignment.center : null,
      decoration: BoxDecoration(
        color: selected ? accent.withValues(alpha: 0.22) : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? accent : AppColors.border,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: !enabled
              ? AppColors.textMuted
              : selected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
        ),
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: chip,
        ),
      ),
    );
  }
}
