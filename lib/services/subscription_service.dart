import 'dart:async';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../config/app_config.dart';
import '../services/firebase_service.dart';

class SubscriptionService {
  static final SubscriptionService instance = SubscriptionService._();
  SubscriptionService._();

  bool _isPro = false;
  bool get isPro => _isPro;

  Future<void> init(String appUserId) async {
    await Purchases.setLogLevel(LogLevel.debug);

    await Purchases.configure(
      PurchasesConfiguration(AppConfig.revenueCatApiKey)
        ..appUserID = appUserId,
    );

    await _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _isPro = customerInfo.entitlements.active
          .containsKey(AppConfig.proEntitlementId);
    } catch (e) {
      _isPro = false;
    }
  }

  Future<bool> purchaseProMonthly() async {
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;

      if (offering == null) return false;

      final package = offering.monthly;
      if (package == null) return false;

      final result = await Purchases.purchase(
        PurchaseParams(package: package),
      );
      _isPro = result.customerInfo.entitlements.active
          .containsKey(AppConfig.proEntitlementId);

      if (_isPro) {
        await FirebaseConfig.logSubscriptionStarted(plan: 'volt_pro_monthly');
      }

      return _isPro;
    } catch (e) {
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _isPro = customerInfo.entitlements.active
          .containsKey(AppConfig.proEntitlementId);
    } catch (e) {
      _isPro = false;
    }
  }

  Future<void> logout() async {
    await Purchases.logOut();
    _isPro = false;
  }
}
