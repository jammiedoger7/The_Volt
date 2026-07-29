# The Volt - Build & Run Instructions

## Prerequisites

- Flutter SDK 3.24.3+
- Android SDK (API 34)
- Java 17+
- Supabase project
- OpenAI API key
- OpenWeatherMap API key
- ClipDrop API key
- RevenueCat account
- Firebase project (optional, for analytics/push)

## Environment Setup

Create a `.env` file in the project root (or use `--dart-define`):

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=OPENAI_API_KEY=sk-... \
  --dart-define=OPENWEATHER_API_KEY=your-weather-key \
  --dart-define=BG_REMOVAL_API_KEY=your-clipdrop-key \
  --dart-define=REVENUECAT_API_KEY=your-revenuecat-key
```

## Database Setup

1. Create a Supabase project at https://supabase.com
2. Go to SQL Editor and run `supabase/schema.sql`
3. Copy the Project URL and Anon Key to your env vars

## Firebase Setup (Optional)

```bash
cd android
flutterfire configure
```

## RevenueCat Setup

1. Create account at https://revenuecat.com
2. Create an app with bundle ID `com.thevolt.app`
3. Create a "Pro" entitlement
4. Create a monthly product (£4.99/month)
5. Copy the API key to your env vars

## Build Commands

```bash
# Run on connected device
flutter run

# Build APK
flutter build apk --release --split-per-abi

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Run tests
flutter test

# Analyze
flutter analyze
```

## Deploy

```bash
cd android/fastlane
bundle install
bundle exec fastlane beta  # Internal testing
bundle exec fastlane release  # Production
```

## Project Structure

```
lib/
  config/          - App configuration constants
  models/          - Data models (WardrobeItem, Outfit, UserProfile, WeatherData)
  providers/       - Riverpod state providers
  screens/         - UI screens
    auth/          - Login, SignUp
    generator/     - Outfit generator, Calendar
    home/          - Dashboard
    onboarding/    - First-time user flow
    settings/      - Settings, Paywall
    wardrobe/      - Grid view, Add item
  services/        - API integrations
    ai_service.dart         - OpenAI Vision + outfit generation
    auth_service.dart       - Supabase Auth
    firebase_service.dart   - Analytics + push
    outfit_generator.dart   - Local outfit algorithm
    subscription_service.dart - RevenueCat
    supabase_service.dart   - Supabase client
    weather_service.dart    - OpenWeatherMap
  theme/           - Colors, typography, theme
  widgets/         - Reusable UI components
    common/        - VoltButton
    generator/     - MannequinDisplay, OutfitResultCard
    wardrobe/      - WardrobeCard
supabase/
  schema.sql       - Full database schema with RLS
android/fastlane/  - Android deployment config
ios/fastlane/      - iOS deployment config
.github/workflows/ - CI/CD pipeline
```
