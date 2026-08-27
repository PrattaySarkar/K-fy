import 'package:flutter/material.dart';

import '../data/subscription_repository.dart';
import 'app_settings.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.settings,
    required this.subscriptions,
    required super.child,
  });

  final AppSettings settings;
  final SubscriptionRepository subscriptions;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in the tree.');
    return scope!;
  }

  static AppSettings settingsOf(BuildContext context) => of(context).settings;

  static SubscriptionRepository subscriptionsOf(BuildContext context) =>
      of(context).subscriptions;

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return settings != oldWidget.settings ||
        subscriptions != oldWidget.subscriptions;
  }
}
