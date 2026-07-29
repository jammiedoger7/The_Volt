import 'package:uuid/uuid.dart';

class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final List<String> preferredStyles;
  final bool isPro;
  final int dailyGenerationsUsed;
  final DateTime lastGenerationDate;
  final DateTime createdAt;

  UserProfile({
    String? id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.preferredStyles = const [],
    this.isPro = false,
    this.dailyGenerationsUsed = 0,
    DateTime? lastGenerationDate,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        lastGenerationDate = lastGenerationDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  bool get canGenerate => isPro || dailyGenerationsUsed < 3;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'preferred_styles': preferredStyles,
      'is_pro': isPro,
      'daily_generations_used': dailyGenerationsUsed,
      'last_generation_date': lastGenerationDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      email: map['email'],
      displayName: map['display_name'],
      avatarUrl: map['avatar_url'],
      preferredStyles: List<String>.from(map['preferred_styles'] ?? []),
      isPro: map['is_pro'] ?? false,
      dailyGenerationsUsed: map['daily_generations_used'] ?? 0,
      lastGenerationDate: DateTime.parse(map['last_generation_date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  UserProfile copyWith({
    String? displayName,
    String? avatarUrl,
    List<String>? preferredStyles,
    bool? isPro,
    int? dailyGenerationsUsed,
  }) {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferredStyles: preferredStyles ?? this.preferredStyles,
      isPro: isPro ?? this.isPro,
      dailyGenerationsUsed: dailyGenerationsUsed ?? this.dailyGenerationsUsed,
      lastGenerationDate: lastGenerationDate,
      createdAt: createdAt,
    );
  }
}
