import '../models/subscription.dart';

enum BillingPeriod { monthly, yearly, freeTrial }

extension BillingPeriodLabel on BillingPeriod {
  String get label => switch (this) {
        BillingPeriod.monthly => 'Monthly',
        BillingPeriod.yearly => 'Yearly',
        BillingPeriod.freeTrial => 'Free Trial',
      };

  String get dateFieldLabel => switch (this) {
        BillingPeriod.freeTrial => 'Expiry date',
        _ => 'Renewal date',
      };
}

enum ReminderLeadTime { onDay, oneDay, twoDays, sevenDays }

extension ReminderLeadTimeLabel on ReminderLeadTime {
  String get label => switch (this) {
        ReminderLeadTime.onDay => 'On the day',
        ReminderLeadTime.oneDay => '1 day before',
        ReminderLeadTime.twoDays => '2 days before',
        ReminderLeadTime.sevenDays => '7 days before',
      };

  int get days => switch (this) {
        ReminderLeadTime.onDay => 0,
        ReminderLeadTime.oneDay => 1,
        ReminderLeadTime.twoDays => 2,
        ReminderLeadTime.sevenDays => 7,
      };
}

enum NotificationIntensity { calm, standard, urgent }

extension NotificationIntensityLabel on NotificationIntensity {
  String get label => switch (this) {
        NotificationIntensity.calm => 'Calm',
        NotificationIntensity.standard => 'Standard',
        NotificationIntensity.urgent => 'Urgent',
      };

  String get hint => switch (this) {
        NotificationIntensity.calm => 'Soft nudge, low risk',
        NotificationIntensity.standard => 'Clear reminder before charge',
        NotificationIntensity.urgent => 'High-risk trial — loud alert',
      };

  static NotificationIntensity fromTrialRisk(DateTime expiryOrRenewal) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(
      expiryOrRenewal.year,
      expiryOrRenewal.month,
      expiryOrRenewal.day,
    );
    final days = target.difference(today).inDays;
    if (days <= 3) return NotificationIntensity.urgent;
    if (days <= 7) return NotificationIntensity.standard;
    return NotificationIntensity.calm;
  }
}

class AddSubscriptionDraft {
  const AddSubscriptionDraft({
    required this.name,
    required this.period,
    required this.cost,
    required this.expiryOrRenewal,
    required this.remindersEnabled,
    required this.remindBefore,
    required this.intensity,
    required this.currency,
  });

  final String name;
  final BillingPeriod period;
  final double cost;
  final DateTime expiryOrRenewal;
  final bool remindersEnabled;
  final ReminderLeadTime remindBefore;
  final NotificationIntensity intensity;
  final String currency;

  bool get isFreeTrial => period == BillingPeriod.freeTrial;

  Subscription toSubscription({required String id}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(
      expiryOrRenewal.year,
      expiryOrRenewal.month,
      expiryOrRenewal.day,
    );
    final days = target.difference(today).inDays;
    return Subscription(
      id: id,
      name: name,
      cost: cost,
      currency: currency,
      billingDate: expiryOrRenewal,
      isTrial: isFreeTrial,
      trialDurationDays: isFreeTrial ? (days < 1 ? 1 : days) : 0,
      remindersEnabled: remindersEnabled,
      reminderLeadDays: remindBefore.days,
      notificationIntensity: switch (intensity) {
        NotificationIntensity.calm =>
          SubscriptionNotificationIntensity.calm,
        NotificationIntensity.urgent =>
          SubscriptionNotificationIntensity.urgent,
        NotificationIntensity.standard =>
          SubscriptionNotificationIntensity.standard,
      },
      cycle: period == BillingPeriod.yearly
          ? BillingCycle.yearly
          : BillingCycle.monthly,
    );
  }
}
