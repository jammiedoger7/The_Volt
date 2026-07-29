class WeatherData {
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final String description;
  final DateTime timestamp;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isCold => temperature < 10;
  bool get isMild => temperature >= 10 && temperature <= 20;
  bool get isWarm => temperature > 20;

  bool get isRaining =>
      condition.toLowerCase().contains('rain') ||
      condition.toLowerCase().contains('drizzle');

  bool get isSnowing => condition.toLowerCase().contains('snow');

  int get recommendedWarmth {
    if (isCold) return 8;
    if (isMild) return 5;
    return 3;
  }

  factory WeatherData.fromOpenWeatherMap(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'] ?? 'Unknown',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num?)?.toDouble() ?? 0,
      description: json['weather'][0]['description'] ?? '',
    );
  }
}
