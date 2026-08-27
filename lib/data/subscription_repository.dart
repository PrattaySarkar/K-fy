import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/subscription.dart';
import 'seed_data.dart';

class SubscriptionRepository extends ChangeNotifier {
  SubscriptionRepository({Box? box}) : _box = box ?? Hive.box(_boxName);

  static const _boxName = 'subscriptions';
  static const _seededKey = 'hasSeeded';

  final Box _box;

  List<Subscription> get all {
    return _box.values
        .whereType<Map>()
        .map(Subscription.fromMap)
        .toList()
      ..sort((a, b) => a.billingDate.compareTo(b.billingDate));
  }

  List<Subscription> get reminders =>
      all.where((item) => item.isTrial && !item.isHistorical).toList();

  List<Subscription> get paidSubscriptions =>
      all.where((item) => !item.isTrial && !item.isHistorical).toList();

  List<Subscription> get history =>
      all.where((item) => item.isHistorical).toList();

  Future<void> seedIfEmpty() async {
    final settings = Hive.box('settings');
    final seeded = settings.get(_seededKey, defaultValue: false) as bool;
    if (seeded || _box.isNotEmpty) return;
    for (final item in SeedData.subscriptions) {
      await _box.put(item.id, item.toMap());
    }
    await settings.put(_seededKey, true);
    notifyListeners();
  }

  Future<void> upsert(Subscription item) async {
    await _box.put(item.id, item.toMap());
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> reset() async {
    await _box.clear();
    await Hive.box('settings').put(_seededKey, true);
    notifyListeners();
  }

  List<Map<String, dynamic>> toJsonList() {
    return all.map((item) => item.toMap()).toList();
  }
}
