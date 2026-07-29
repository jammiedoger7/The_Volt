import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/weather_data.dart';

class WeatherService {
  static final WeatherService instance = WeatherService._();
  WeatherService._();

  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherData> getCurrentWeather(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&units=metric&appid=${AppConfig.openWeatherApiKey}',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeatherData.fromOpenWeatherMap(data);
    }
    throw Exception('Failed to fetch weather: ${response.body}');
  }

  Future<WeatherData> getWeatherByCity(String city) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/weather?q=$city&units=metric&appid=${AppConfig.openWeatherApiKey}',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeatherData.fromOpenWeatherMap(data);
    }
    throw Exception('Failed to fetch weather: ${response.body}');
  }
}
