import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';

final weatherProvider = StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherData?>>((ref) {
  return WeatherNotifier();
});

class WeatherNotifier extends StateNotifier<AsyncValue<WeatherData?>> {
  WeatherNotifier() : super(const AsyncValue.data(null));

  final _service = WeatherService.instance;

  Future<void> loadWeather(double lat, double lon) async {
    state = const AsyncValue.loading();
    try {
      final weather = await _service.getCurrentWeather(lat, lon);
      state = AsyncValue.data(weather);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadByCity(String city) async {
    state = const AsyncValue.loading();
    try {
      final weather = await _service.getWeatherByCity(city);
      state = AsyncValue.data(weather);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
