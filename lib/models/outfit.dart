import 'package:uuid/uuid.dart';

class Outfit {
  final String id;
  final String userId;
  final String? name;
  final String? topId;
  final String? bottomId;
  final String? shoesId;
  final String? outerwearId;
  final List<String> accessoryIds;
  final int? rating;
  final bool isSaved;
  final String? weatherCondition;
  final double? temperature;
  final DateTime createdAt;

  Outfit({
    String? id,
    required this.userId,
    this.name,
    this.topId,
    this.bottomId,
    this.shoesId,
    this.outerwearId,
    this.accessoryIds = const [],
    this.rating,
    this.isSaved = false,
    this.weatherCondition,
    this.temperature,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'top_id': topId,
      'bottom_id': bottomId,
      'shoes_id': shoesId,
      'outerwear_id': outerwearId,
      'accessory_ids': accessoryIds,
      'rating': rating,
      'is_saved': isSaved,
      'weather_condition': weatherCondition,
      'temperature': temperature,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Outfit.fromMap(Map<String, dynamic> map) {
    return Outfit(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      topId: map['top_id'],
      bottomId: map['bottom_id'],
      shoesId: map['shoes_id'],
      outerwearId: map['outerwear_id'],
      accessoryIds: List<String>.from(map['accessory_ids'] ?? []),
      rating: map['rating'],
      isSaved: map['is_saved'] ?? false,
      weatherCondition: map['weather_condition'],
      temperature: map['temperature']?.toDouble(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Outfit copyWith({
    String? name,
    String? topId,
    String? bottomId,
    String? shoesId,
    String? outerwearId,
    List<String>? accessoryIds,
    int? rating,
    bool? isSaved,
  }) {
    return Outfit(
      id: id,
      userId: userId,
      name: name ?? this.name,
      topId: topId ?? this.topId,
      bottomId: bottomId ?? this.bottomId,
      shoesId: shoesId ?? this.shoesId,
      outerwearId: outerwearId ?? this.outerwearId,
      accessoryIds: accessoryIds ?? this.accessoryIds,
      rating: rating ?? this.rating,
      isSaved: isSaved ?? this.isSaved,
      weatherCondition: weatherCondition,
      temperature: temperature,
      createdAt: createdAt,
    );
  }
}
