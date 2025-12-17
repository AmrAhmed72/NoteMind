import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

enum AIAction {
  rewriteFormal,
  correctGrammar,
  summarize,
}

class AIService {
  // ✅ استخدم أحدث موديل مدعوم من Google
  final String baseUrl =
      "${APIConfig.geminiBaseUrl}/${APIConfig.geminiModel}:generateContent";

  bool get isConfigured => APIConfig.isGeminiConfigured;

  // Add a flag to prevent multiple requests from being sent simultaneously
  bool isProcessing = false;

  // Add a loading state to ensure smooth UI updates
  bool isLoading = false;

  String _getPrompt(AIAction action, String text) {
    switch (action) {
      case AIAction.rewriteFormal:
        return '''
Rewrite the following text in a more formal, polished, and professional tone. 
Keep the same meaning and key points, but improve the language quality and formality.

Text to rewrite:
$text

Provide only the rewritten text without any explanations or comments.
''';

      case AIAction.correctGrammar:
        return '''
Correct any grammar, spelling, and punctuation errors in the following text. 
Keep the same meaning, tone, and style. Only fix errors without changing the content.

Text to correct:
$text

Provide only the corrected text without any explanations or comments.
''';

      case AIAction.summarize:
        return '''
Create a short and concise summary of the following text. 
Focus on the key points and main ideas. Keep it clear and brief.

Text to summarize:
$text

Provide only the summary without any explanations or comments.
''';
    }
  }

  String getActionName(AIAction action) {
    switch (action) {
      case AIAction.rewriteFormal:
        return 'Rewrite Formally';
      case AIAction.correctGrammar:
        return 'Correct Grammar';
      case AIAction.summarize:
        return 'Summarize';
    }
  }

  String getActionIcon(AIAction action) {
    switch (action) {
      case AIAction.rewriteFormal:
        return '✍️';
      case AIAction.correctGrammar:
        return '🧩';
      case AIAction.summarize:
        return '✂️';
    }
  }

  Future<String> processText(AIAction action, String text) async {
    if (!isConfigured) {
      throw Exception(
          'Gemini API key not configured. Please add it in lib/config/api_config.dart');
    }

    if (text.trim().isEmpty) {
      throw Exception('Text cannot be empty');
    }

    if (isProcessing || isLoading) {
      throw Exception('A request is already in progress. Please wait.');
    }

    isProcessing = true;
    isLoading = true;

    try {
      final prompt = _getPrompt(action, text);
      final url = Uri.parse('$baseUrl?key=${APIConfig.geminiApiKey}');

      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      });

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result =
            data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
        if (result == null || result.trim().isEmpty) {
          throw Exception('Empty response from Gemini');
        }
        return result.trim();
      } else {
        throw Exception(
            "Error: ${response.statusCode} - ${response.reasonPhrase}\n${response.body}");
      }
    } catch (e) {
      print('Gemini API Error: $e');
      rethrow;
    } finally {
      isProcessing = false;
      isLoading = false;
    }
  }

  int estimateTokens(String text) => (text.length / 4).ceil();

  bool isTextTooLong(String text) => estimateTokens(text) > 3000;
}
