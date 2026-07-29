import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String appName = 'The Volt';
  static const String appTagline = 'AI-Powered Outfit Generator';

  // Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // OpenAI
  static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  // OpenWeatherMap
  static String get openWeatherApiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  // ClipDrop / remove.bg
  static String get backgroundRemovalApiKey => dotenv.env['BG_REMOVAL_API_KEY'] ?? '';

  // RevenueCat
  static String get revenueCatApiKey => dotenv.env['REVENUECAT_API_KEY'] ?? '';

  // Pro subscription
  static const double proMonthlyPrice = 4.99;
  static const String proEntitlementId = 'volt_pro';
  static const int freeDailyGenerations = 3;
}
