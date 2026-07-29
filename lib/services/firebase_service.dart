import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> init() async {
    debugPrint('Firebase: skipped (disabled for Windows dev build)');
  }

  static Future<void> logOutfitGenerated() async {}
  static Future<void> logOutfitSaved() async {}
  static Future<void> logItemScanned({required String category}) async {}
  static Future<void> logBackgroundRemoved() async {}
  static Future<void> logPaywallViewed() async {}
  static Future<void> logSubscriptionStarted({required String plan}) async {}
  static Future<void> setUserProperties({required String userId, bool isPro = false}) async {}
}
