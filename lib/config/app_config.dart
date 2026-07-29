import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String appName = 'The Volt';
  static const String appTagline = 'AI-Powered Outfit Generator';

  static String _fromEnv(String key) =>
      dotenv.env[key] ?? const String.fromEnvironment(key, defaultValue: '');

  // Supabase
  static String get supabaseUrl => _fromEnv('SUPABASE_URL');
  static String get supabaseAnonKey => _fromEnv('SUPABASE_ANON_KEY');

  // OpenAI
  static String get openAiApiKey => _fromEnv('OPENAI_API_KEY');

  // OpenWeatherMap
  static String get openWeatherApiKey => _fromEnv('OPENWEATHER_API_KEY');

  // ClipDrop / remove.bg
  static String get backgroundRemovalApiKey => _fromEnv('BG_REMOVAL_API_KEY');

  // RevenueCat
  static String get revenueCatApiKey => _fromEnv('REVENUECAT_API_KEY');

  // Pro subscription
  static const double proMonthlyPrice = 4.99;
  static const String proEntitlementId = 'volt_pro';
  static const int freeDailyGenerations = 3;
}
