import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

enum SubscriptionPlan { free, proMonthly, proYearly, proLifetime }

class SubscriptionService {
  final SharedPreferences _prefs;

  SubscriptionService(this._prefs);

  bool get isPro {
    if (!_prefs.getBool(AppConstants.keyIsPro) == false) return false;
    final isPro = _prefs.getBool(AppConstants.keyIsPro) ?? false;
    if (!isPro) return false;

    final expiryMs = _prefs.getInt(AppConstants.keyProExpiry);
    if (expiryMs == null) return true; // lifetime
    return DateTime.fromMillisecondsSinceEpoch(expiryMs)
        .isAfter(DateTime.now());
  }

  bool canProcessMoreScreenshots(int currentCount) {
    if (isPro) return true;
    return currentCount < AppConstants.freeScreenshotLimit;
  }

  int get remainingFreeSlots {
    final scanned = _prefs.getInt(AppConstants.keyTotalScanned) ?? 0;
    if (isPro) return -1; // unlimited
    final remaining = AppConstants.freeScreenshotLimit - scanned;
    return remaining < 0 ? 0 : remaining;
  }

  double get freeUsagePercent {
    if (isPro) return 0.0;
    final scanned = _prefs.getInt(AppConstants.keyTotalScanned) ?? 0;
    return (scanned / AppConstants.freeScreenshotLimit).clamp(0.0, 1.0);
  }

  Future<void> activatePro(SubscriptionPlan plan) async {
    await _prefs.setBool(AppConstants.keyIsPro, true);
    if (plan == SubscriptionPlan.proMonthly) {
      final expiry = DateTime.now().add(const Duration(days: 31));
      await _prefs.setInt(
          AppConstants.keyProExpiry, expiry.millisecondsSinceEpoch);
    } else if (plan == SubscriptionPlan.proYearly) {
      final expiry = DateTime.now().add(const Duration(days: 365));
      await _prefs.setInt(
          AppConstants.keyProExpiry, expiry.millisecondsSinceEpoch);
    } else {
      // Lifetime — no expiry
      await _prefs.remove(AppConstants.keyProExpiry);
    }
  }

  Future<void> incrementScannedCount(int count) async {
    final current = _prefs.getInt(AppConstants.keyTotalScanned) ?? 0;
    await _prefs.setInt(AppConstants.keyTotalScanned, current + count);
  }

  Future<void> resetForTesting() async {
    await _prefs.remove(AppConstants.keyIsPro);
    await _prefs.remove(AppConstants.keyProExpiry);
    await _prefs.remove(AppConstants.keyTotalScanned);
  }
}
