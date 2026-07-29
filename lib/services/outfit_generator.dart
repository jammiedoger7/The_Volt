import 'dart:math';
import '../models/wardrobe_item.dart';
import '../models/outfit.dart';
import '../models/weather_data.dart';

class OutfitGenerator {
  static final OutfitGenerator instance = OutfitGenerator._();
  OutfitGenerator._();

  Outfit generateOutfit({
    required List<WardrobeItem> wardrobe,
    required WeatherData weather,
    required List<String> preferredStyles,
    String? occasion,
  }) {
    final tops = wardrobe
        .where((item) => item.category == ClothingCategory.tops)
        .toList();
    final bottoms = wardrobe
        .where((item) => item.category == ClothingCategory.bottoms)
        .toList();
    final shoes = wardrobe
        .where((item) => item.category == ClothingCategory.shoes)
        .toList();
    final outerwear = wardrobe
        .where((item) => item.category == ClothingCategory.outerwear)
        .toList();
    final accessories = wardrobe
        .where((item) => item.category == ClothingCategory.accessories)
        .toList();

    if (tops.isEmpty || bottoms.isEmpty || shoes.isEmpty) {
      throw Exception(
        'Need at least a top, bottom, and shoes to generate an outfit',
      );
    }

    final scoredTops = _scoreItems(tops, weather, preferredStyles);
    final scoredBottoms = _scoreItems(bottoms, weather, preferredStyles);
    final scoredShoes = _scoreItems(shoes, weather, preferredStyles);

    final bestTop = scoredTops.first;
    final bestBottom = scoredBottoms.first;
    final bestShoes = scoredShoes.first;

    String? bestOuterwear;
    if (weather.isCold || weather.isRaining) {
      if (outerwear.isNotEmpty) {
        bestOuterwear =
            _scoreItems(outerwear, weather, preferredStyles).first;
      }
    }

    final selectedAccessories = accessories.take(2).map((a) => a.id).toList();

    return Outfit(
      userId: '',
      topId: bestTop,
      bottomId: bestBottom,
      shoesId: bestShoes,
      outerwearId: bestOuterwear,
      accessoryIds: selectedAccessories,
      weatherCondition: weather.condition,
      temperature: weather.temperature,
    );
  }

  List<String> _scoreItems(
    List<WardrobeItem> items,
    WeatherData weather,
    List<String> preferredStyles,
  ) {
    final scored = items.map((item) {
      double score = 0;

      if (weather.isCold && item.warmthRating >= 6) score += 3;
      if (weather.isWarm && item.warmthRating <= 4) score += 3;
      if (weather.isMild) score += 2;

      if (item.style != null &&
          preferredStyles.contains(item.style!.name)) {
        score += 2;
      }

      score += Random().nextDouble();

      return MapEntry(item.id, score);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }
}
