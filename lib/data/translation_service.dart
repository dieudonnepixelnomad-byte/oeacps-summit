import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class TranslationService {
  final String _apiKey = kWeglotApiKey;
  final String _apiUrl = kWeglotApiUrl;

  /// Traduit une liste de textes
  Future<List<String>> translateTexts({
    required List<String> texts,
    String fromLang = 'fr',
    required String toLang,
  }) async {
    if (texts.isEmpty) return [];
    if (fromLang == toLang) return texts;

    // Weglot API limit handling could be added here if needed
    // For now, we assume reasonable batch sizes

    try {
      final requestBody = jsonEncode({
        "l_from": fromLang,
        "l_to": toLang,
        "bot": 0,
        "request_url": "https://summitoacps.com",
        "words": texts.map((w) => {"w": w, "t": 1}).toList(),
      });

      developer.log(
        'Sending translation request for ${texts.length} items to $toLang',
        name: 'TranslationService',
      );
      developer.log('Request body: $requestBody', name: 'TranslationService');

      final response = await http.post(
        Uri.parse('$_apiUrl?api_key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      developer.log(
        'Translation response status: ${response.statusCode}',
        name: 'TranslationService',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        developer.log(
          'Translation response data: $data',
          name: 'TranslationService',
        );
        final toWords = data['to_words'] as List;
        return toWords.map((e) => e.toString()).toList();
      } else {
        developer.log(
          'Weglot API Error: ${response.body}',
          name: 'TranslationService',
        );
        // Fallback: return original texts
        return texts;
      }
    } catch (e) {
      developer.log('Translation Error: $e', name: 'TranslationService');
      return texts;
    }
  }
}
