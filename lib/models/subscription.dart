enum BillingCycle { monthly, yearly }

enum SubscriptionNotificationIntensity { calm, standard, urgent }

extension BillingCycleLabel on BillingCycle {
  String get label => switch (this) {
        BillingCycle.monthly => 'Monthly',
        BillingCycle.yearly => 'Yearly',
      };
}

enum UrgencyLevel { healthy, warning, critical }

class Subscription {
  const Subscription({
    required this.id,
    required this.name,
    required this.cost,
    required this.currency,
    required this.billingDate,
    required this.isTrial,
    required this.trialDurationDays,
    this.remindersEnabled = true,
    this.reminderLeadDays = 3,
    this.notificationIntensity = SubscriptionNotificationIntensity.standard,
    this.cycle = BillingCycle.monthly,
    this.isActive = true,
    this.isHistorical = false,
    this.monogram,
  });

  final String id;
  final String name;
  final double cost;
  final String currency;
  final DateTime billingDate;
  final bool isTrial;
  final int trialDurationDays;
  final bool remindersEnabled;
  final int reminderLeadDays;
  final SubscriptionNotificationIntensity notificationIntensity;
  final BillingCycle cycle;
  final bool isActive;
  final bool isHistorical;
  final String? monogram;

  String get initials {
    if (monogram != null && monogram!.isNotEmpty) return monogram!;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.isEmpty
          ? '?'
          : parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(
      billingDate.year,
      billingDate.month,
      billingDate.day,
    );
    final days = target.difference(today).inDays;
    return days < 0 ? 0 : days;
  }

  UrgencyLevel get urgency {
    if (isHistorical) return UrgencyLevel.healthy;
    if (daysRemaining <= 3) return UrgencyLevel.critical;
    if (daysRemaining <= 7) return UrgencyLevel.warning;
    return UrgencyLevel.healthy;
  }

  String get statusLabel {
    if (isHistorical) {
      return daysRemaining == 0 ? 'Cancelled' : 'Ended';
    }
    if (isTrial && urgency == UrgencyLevel.critical) {
      final unit = daysRemaining == 1 ? 'Day' : 'Days';
      return 'Expiring Soon ($daysRemaining $unit)';
    }
    if (isTrial) return 'Days Left: $daysRemaining Days';
    return 'Next billing';
  }

  Subscription copyWith({
    String? name,
    double? cost,
    String? currency,
    DateTime? billingDate,
    bool? isTrial,
    int? trialDurationDays,
    bool? remindersEnabled,
    int? reminderLeadDays,
    SubscriptionNotificationIntensity? notificationIntensity,
    BillingCycle? cycle,
    bool? isActive,
    bool? isHistorical,
  }) {
    return Subscription(
      id: id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      billingDate: billingDate ?? this.billingDate,
      isTrial: isTrial ?? this.isTrial,
      trialDurationDays: trialDurationDays ?? this.trialDurationDays,
        remindersEnabled: remindersEnabled ?? this.remindersEnabled,
        reminderLeadDays: reminderLeadDays ?? this.reminderLeadDays,
        notificationIntensity:
          notificationIntensity ?? this.notificationIntensity,
      cycle: cycle ?? this.cycle,
      isActive: isActive ?? this.isActive,
      isHistorical: isHistorical ?? this.isHistorical,
      monogram: monogram,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cost': cost,
      'currency': currency,
      'billingDate': billingDate.toIso8601String(),
      'isTrial': isTrial,
      'trialDurationDays': trialDurationDays,
      'remindersEnabled': remindersEnabled,
      'reminderLeadDays': reminderLeadDays,
      'notificationIntensity': notificationIntensity.name,
      'cycle': cycle.name,
      'isActive': isActive,
      'isHistorical': isHistorical,
      'monogram': monogram,
    };
  }

  factory Subscription.fromMap(Map<dynamic, dynamic> map) {
    final cycleName = map['cycle'] as String? ?? 'monthly';
    final intensityName = map['notificationIntensity'] as String? ?? 'standard';
    final rawDate = map['billingDate'];
    final parsedDate = rawDate is String ? DateTime.tryParse(rawDate) : null;
    return Subscription(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown service',
      cost: map['cost'] is num ? (map['cost'] as num).toDouble() : 0,
      currency: map['currency'] as String? ?? 'USD',
      billingDate: parsedDate ?? DateTime.now(),
      isTrial: map['isTrial'] as bool? ?? false,
      trialDurationDays: _intValue(map['trialDurationDays']),
      remindersEnabled: map['remindersEnabled'] as bool? ?? true,
      reminderLeadDays: _intValue(map['reminderLeadDays'], fallback: 3),
      notificationIntensity: switch (intensityName) {
        'calm' => SubscriptionNotificationIntensity.calm,
        'urgent' => SubscriptionNotificationIntensity.urgent,
        _ => SubscriptionNotificationIntensity.standard,
      },
      cycle: cycleName == 'yearly' ? BillingCycle.yearly : BillingCycle.monthly,
      isActive: map['isActive'] as bool? ?? true,
      isHistorical: map['isHistorical'] as bool? ?? false,
      monogram: map['monogram'] as String?,
    );
  }

  static int _intValue(Object? value, {int fallback = 0}) {
    return value is num ? value.toInt() : fallback;
  }
}
