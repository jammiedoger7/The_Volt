import 'package:uuid/uuid.dart';

enum ClothingCategory {
  tops,
  bottoms,
  shoes,
  outerwear,
  accessories,
}

enum ClothingStyle {
  casual,
  formal,
  streetwear,
  athletic,
  smart,
  vintage,
}

enum Season {
  spring,
  summer,
  autumn,
  winter,
}

class WardrobeItem {
  final String id;
  final String userId;
  final String name;
  final ClothingCategory category;
  final String color;
  final String? material;
  final String? brand;
  final ClothingStyle? style;
  final String imageUrl;
  final String? transparentImageUrl;
  final List<Season> suitableSeasons;
  final int warmthRating;
  final DateTime createdAt;

  WardrobeItem({
    String? id,
    required this.userId,
    required this.name,
    required this.category,
    required this.color,
    this.material,
    this.brand,
    this.style,
    required this.imageUrl,
    this.transparentImageUrl,
    this.suitableSeasons = const [],
    this.warmthRating = 5,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category.name,
      'color': color,
      'material': material,
      'brand': brand,
      'style': style?.name,
      'image_url': imageUrl,
      'transparent_image_url': transparentImageUrl,
      'suitable_seasons': suitableSeasons.map((s) => s.name).toList(),
      'warmth_rating': warmthRating,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WardrobeItem.fromMap(Map<String, dynamic> map) {
    return WardrobeItem(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      category: ClothingCategory.values.byName(map['category']),
      color: map['color'],
      material: map['material'],
      brand: map['brand'],
      style: map['style'] != null
          ? ClothingStyle.values.byName(map['style'])
          : null,
      imageUrl: map['image_url'],
      transparentImageUrl: map['transparent_image_url'],
      suitableSeasons: (map['suitable_seasons'] as List?)
              ?.map((s) => Season.values.byName(s))
              .toList() ??
          [],
      warmthRating: map['warmth_rating'] ?? 5,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  WardrobeItem copyWith({
    String? name,
    ClothingCategory? category,
    String? color,
    String? material,
    String? brand,
    ClothingStyle? style,
    String? imageUrl,
    String? transparentImageUrl,
    List<Season>? suitableSeasons,
    int? warmthRating,
  }) {
    return WardrobeItem(
      id: id,
      userId: userId,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      material: material ?? this.material,
      brand: brand ?? this.brand,
      style: style ?? this.style,
      imageUrl: imageUrl ?? this.imageUrl,
      transparentImageUrl: transparentImageUrl ?? this.transparentImageUrl,
      suitableSeasons: suitableSeasons ?? this.suitableSeasons,
      warmthRating: warmthRating ?? this.warmthRating,
      createdAt: createdAt,
    );
  }
}
