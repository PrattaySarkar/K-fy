import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:kfy/app/app_settings.dart';
import 'package:kfy/bootstrap.dart';
import 'package:kfy/data/subscription_repository.dart';
import 'package:kfy/main.dart';

void main() {
  late Directory dir;
  late AppSettings settings;
  late SubscriptionRepository subscriptions;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('kfy_test_');
    await bootstrap(hivePath: dir.path);
    settings = AppSettings();
    subscriptions = SubscriptionRepository();
    await subscriptions.seedIfEmpty();
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('subscriptions');
    await Hive.deleteBoxFromDisk('settings');
    await Hive.close();
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  });

  testWidgets('Home dashboard shows savings and tabs', (tester) async {
    await tester.pumpWidget(
      KfyApp(
        settings: settings,
        subscriptions: subscriptions,
        showSplash: false,
      ),
    );
    await tester.pump();

    expect(find.text('K.fy'), findsOneWidget);
    expect(find.text('Saved till date'), findsOneWidget);
    expect(find.text('Reminders'), findsOneWidget);
    expect(find.text('Subscriptions'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Add Subscription'), findsOneWidget);
    expect(find.text('Cursor'), findsOneWidget);
  });

  testWidgets('Add Subscription sheet shows form fields', (tester) async {
    await tester.pumpWidget(
      KfyApp(
        settings: settings,
        subscriptions: subscriptions,
        showSplash: false,
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Add Subscription'));
    await tester.pumpAndSettle();

    expect(find.text('Add New Subscription'), findsOneWidget);
    expect(
      find.text('Enter service name, e.g., Netflix, Cursor'),
      findsOneWidget,
    );
    expect(find.text('Save Subscription'), findsOneWidget);
  });
}
