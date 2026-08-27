import 'package:hive_flutter/hive_flutter.dart';

import 'widgets/film_grain.dart';

Future<void> bootstrap({String? hivePath}) async {
  if (hivePath != null) {
    Hive.init(hivePath);
  } else {
    await Hive.initFlutter();
  }
  if (!Hive.isBoxOpen('subscriptions')) {
    await Hive.openBox('subscriptions');
  }
  if (!Hive.isBoxOpen('settings')) {
    await Hive.openBox('settings');
  }
  await GrainCache.ensure();
}
