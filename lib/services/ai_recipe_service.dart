import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../models/grocery_item.dart';
import '../utils/constants.dart';

class AiRecipeService {
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  // Cache the discovered model so we only call ListModels once per session,
  // halving API quota consumption.
  static String? _cachedModel;

  static Future<String?> _findAvailableModel() async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=${Constants.geminiApiKey}',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final models = (data['models'] as List<dynamic>? ?? []);

        const preferred = [
          'gemini-2.5-flash',
          'gemini-2.0-flash-lite',
          'gemini-2.0-flash',
          'gemini-1.5-flash',
          'gemini-1.5-pro',
          'gemini-pro',
        ];

        final supported = models
            .where((m) {
              final methods = (m['supportedGenerationMethods'] as List?) ?? [];
              return methods.contains('generateContent');
            })
            .map((m) => m['name'].toString().replaceFirst('models/', ''))
            .toList();

        print('InvenTrack AI: Models supporting generateContent: $supported');

        for (final pref in preferred) {
          final match = supported.firstWhere(
            (m) => m.startsWith(pref),
            orElse: () => '',
          );
          if (match.isNotEmpty) return match;
        }

        if (supported.isNotEmpty) return supported.first;
      } else {
        print(
          'InvenTrack AI: ListModels failed: ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('InvenTrack AI: ListModels exception: $e');
    }
    return null;
  }

  static Future<Recipe?> generateRecipeFromPantry(
    List<GroceryItem> items,
  ) async {
    if (Constants.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      throw Exception('Please provide a valid Gemini API Key in Constants.');
    }

    _cachedModel ??= await _findAvailableModel();
    if (_cachedModel == null) {
      throw Exception(
        'Could not find a supported Gemini model for your API key. '
        'Check your key at aistudio.google.com.',
      );
    }

    final pantryList = items
        .map((item) => '${item.quantity} ${item.unit} ${item.name}')
        .join(', ');

    final prompt =
        '''
You are a chef. Create ONE simple recipe using ONLY these pantry items: $pantryList
Basic seasonings (salt, pepper, oil, water) are available.

Rules:
- Maximum 6 ingredients
- Maximum 6 instruction steps
- Keep the recipe name short (under 8 words)
- Each instruction step must be under 20 words

Respond with ONLY this exact JSON structure, no markdown, no code fences:
{"name":"Recipe Name","ingredients":[{"name":"ingredient","quantity":1.0,"unit":"unit"}],"instructions":["Step 1.","Step 2."]}
''';

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 4096},
    });

    final fallbackModels = [
      _cachedModel!,
      'gemini-2.5-flash',
      'gemini-2.0-flash-lite',
      'gemini-2.0-flash',
      'gemini-1.5-flash',
    ].toSet().toList();

    for (final model in fallbackModels) {
      print('InvenTrack AI: Trying model: $model');
      final url = Uri.parse(
        '$_baseUrl/$model:generateContent?key=${Constants.geminiApiKey}',
      );

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        _cachedModel = model;
        final jsonResponse = jsonDecode(response.body);

        final finishReason =
            jsonResponse['candidates']?[0]?['finishReason'] as String? ?? '';
        if (finishReason == 'MAX_TOKENS') {
          throw Exception(
            'The AI response was cut off (too long). '
            'Try with fewer pantry items to get a simpler recipe.',
          );
        }

        print(
          'InvenTrack AI: Recipe generated successfully with $model! finishReason=$finishReason',
        );

        final text =
            jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text']
                as String?;

        if (text != null) {
          String cleanJson = text.trim();

          cleanJson = cleanJson
              .replaceAll(RegExp(r'^```(?:json)?\.?\s*', multiLine: true), '')
              .replaceAll(RegExp(r'^```\s*$', multiLine: true), '')
              .trim();
          final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleanJson);
          if (jsonMatch != null) cleanJson = jsonMatch.group(0)!;

          try {
            final data = jsonDecode(cleanJson);
            return Recipe.fromMap(data);
          } catch (e) {
            throw Exception('Failed to parse recipe JSON: $e\nRaw: $text');
          }
        }
      } else if (response.statusCode == 429) {
        print('InvenTrack AI: Quota exceeded for $model, trying next model...');
        _cachedModel = null;
        continue;
      } else {
        final errorBody = response.body;
        print(
          'InvenTrack AI: Generate failed: ${response.statusCode}: $errorBody',
        );
        final errorMsg =
            jsonDecode(errorBody)['error']?['message'] as String? ?? errorBody;
        throw Exception('API Error ($model): $errorMsg');
      }
    }

    // All models exhausted
    throw Exception(
      'All Gemini models have hit their quota limit.\n'
      'Please wait a minute and try again, or visit https://aistudio.google.com to check your quota.',
    );
  }
}
