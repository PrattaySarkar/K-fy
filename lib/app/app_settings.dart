import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

enum GrainIntensity { subtle, strong }

class AppSettings extends ChangeNotifier {
  AppSettings({Box? box}) : _box = box ?? Hive.box(_boxName);

  static const _boxName = 'settings';

  final Box _box;

  String get currencyCode =>
      _box.get('currencyCode', defaultValue: 'USD') as String;

  GrainIntensity get grainIntensity {
    final raw = _box.get('grainIntensity', defaultValue: 'subtle') as String;
    return raw == 'strong' ? GrainIntensity.strong : GrainIntensity.subtle;
  }

  bool get oledTrueBlack =>
      _box.get('oledTrueBlack', defaultValue: false) as bool;

  bool get biometricLock =>
      _box.get('biometricLock', defaultValue: false) as bool;

  bool get globalNotifications =>
      _box.get('globalNotifications', defaultValue: true) as bool;

  int get trialExpiryDays {
    final value = _box.get('trialExpiryDays', defaultValue: 3);
    return value is int ? value : 3;
  }

  bool get renewalReminders =>
      _box.get('renewalReminders', defaultValue: true) as bool;

  double get savedTillDate {
    final value = _box.get('savedTillDate', defaultValue: 103.32);
    if (value is num) return value.toDouble();
    return 103.32;
  }

  String get profileName =>
      _box.get('profileName', defaultValue: 'Alex Rivera') as String;

  String get profileEmail =>
      _box.get('profileEmail', defaultValue: 'alex@k.fy.app') as String;

  double get grainOpacity {
    return switch (grainIntensity) {
      GrainIntensity.subtle => 0.07,
      GrainIntensity.strong => 0.16,
    };
  }

  Future<void> setCurrencyCode(String code) => _set('currencyCode', code);

  Future<void> setGrainIntensity(GrainIntensity value) =>
      _set('grainIntensity', value.name);

  Future<void> setOledTrueBlack(bool value) => _set('oledTrueBlack', value);

  Future<void> setBiometricLock(bool value) => _set('biometricLock', value);

  Future<void> setGlobalNotifications(bool value) =>
      _set('globalNotifications', value);

  Future<void> setTrialExpiryDays(int value) => _set('trialExpiryDays', value);

  Future<void> setRenewalReminders(bool value) =>
      _set('renewalReminders', value);

  Future<void> setSavedTillDate(double value) => _set('savedTillDate', value);

  Future<void> addToSavings(double amount) {
    return setSavedTillDate(savedTillDate + amount);
  }

  Future<void> reset() async {
    await _box.clear();
    await _box.put('savedTillDate', 0.0);
    notifyListeners();
  }

  Future<void> _set(String key, Object value) async {
    await _box.put(key, value);
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyCode': currencyCode,
      'grainIntensity': grainIntensity.name,
      'oledTrueBlack': oledTrueBlack,
      'biometricLock': biometricLock,
      'globalNotifications': globalNotifications,
      'trialExpiryDays': trialExpiryDays,
      'renewalReminders': renewalReminders,
      'savedTillDate': savedTillDate,
      'profileName': profileName,
      'profileEmail': profileEmail,
    };
  }
}
