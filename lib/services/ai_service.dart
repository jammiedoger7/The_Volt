import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/wardrobe_item.dart';

class AIService {
  static final AIService instance = AIService._();
  AIService._();

  final String _baseUrl = 'https://api.openai.com/v1';

  Future<Map<String, String>> analyzeClothing(String imageUrl) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${AppConfig.openAiApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content':
                'Analyze clothing images and return JSON with: category (tops/bottoms/shoes/outerwear/accessories), color, material, brand (if visible), style (casual/formal/streetwear/athletic/smart/vintage), suitable_seasons (array of spring/summer/autumn/winter), warmth_rating (1-10).',
          },
          {
            'role': 'user',
            'content': [
              {
                'type': 'image_url',
                'image_url': {'url': imageUrl},
              },
              {
                'type': 'text',
                'text': 'Analyze this clothing item. Return only valid JSON.',
              },
            ],
          },
        ],
        'max_tokens': 500,
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return Map<String, String>.from(jsonDecode(content) as Map);
    }
    throw Exception('Failed to analyze clothing: ${response.body}');
  }

  Future<List<Map<String, dynamic>>> generateOutfit({
    required List<WardrobeItem> wardrobe,
    required String weatherCondition,
    required double temperature,
    required List<String> preferredStyles,
    String? occasion,
  }) async {
    final wardrobeJson = wardrobe.map((item) => item.toMap()).toList();

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${AppConfig.openAiApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a fashion stylist AI. Given a wardrobe, weather, and style preferences, generate the best outfit. Consider colour theory, warmth rating, and occasion appropriateness. Return JSON array of outfit objects with top_id, bottom_id, shoes_id, outerwear_id, accessory_ids, and a brief explanation.',
          },
          {
            'role': 'user',
            'content':
                'Wardrobe: ${jsonEncode(wardrobeJson)}\n'
                'Weather: $weatherCondition, ${temperature}°C\n'
                'Preferred styles: ${preferredStyles.join(", ")}\n'
                'Occasion: ${occasion ?? "general"}\n'
                'Generate 3 outfit options.',
          },
        ],
        'max_tokens': 1500,
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      final result = jsonDecode(content);
      return List<Map<String, dynamic>>.from(result['outfits'] ?? result);
    }
    throw Exception('Failed to generate outfit: ${response.body}');
  }

  Future<String> removeBackground(String imagePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.clipdrop.co/remove-bg/v1'),
    );
    request.headers['x-api-key'] = AppConfig.backgroundRemovalApiKey;
    request.files.add(await http.MultipartFile.fromPath('image_file', imagePath));

    final streamedResponse = await request.send();
    final responseBytes = await streamedResponse.stream.toBytes();

    if (streamedResponse.statusCode == 200) {
      return base64Encode(responseBytes);
    }
    throw Exception('Failed to remove background: ${streamedResponse.statusCode}');
  }
}
