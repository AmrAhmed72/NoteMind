import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/api_config.dart';
import '../models/note_model.dart';

class ScannedChecklist {
  final String title;
  final List<ChecklistItem> items;

  const ScannedChecklist({required this.title, required this.items});
}

class GeminiScanException implements Exception {
  final String message;

  const GeminiScanException(this.message);

  @override
  String toString() => message;
}

class GeminiVisionService {
  static const _prompt = '''
Analyze this image and extract only actionable tasks into a checklist.
The image may contain printed or handwritten text, existing checkboxes, to-do lists,
shopping lists, meeting notes, or study notes. Tasks may be in Arabic, English, or a
mixture of both. Preserve the original meaning, wording, and language. Do not invent
tasks, add information, or include decorative text. Preserve an item's checked state;
use false when its state cannot be determined. Keep each item concise.

Return only the requested JSON object with this exact shape:
{"title":"string","items":[{"text":"string","completed":false}]}
''';

  Future<ScannedChecklist> analyzeImage(
    Uint8List imageBytes, {
    required String mimeType,
  }) async {
    if (!APIConfig.isGeminiConfigured) {
      throw const GeminiScanException(
        'Gemini is not configured. Add GEMINI_API_KEY with --dart-define.',
      );
    }
    if (imageBytes.isEmpty) {
      throw const GeminiScanException('The selected image is invalid or empty.');
    }

    final model = GenerativeModel(
      model: APIConfig.geminiModel,
      apiKey: APIConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.1,
        maxOutputTokens: APIConfig.maxTokensPerRequest,
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          requiredProperties: ['title', 'items'],
          properties: {
            'title': Schema.string(),
            'items': Schema.array(
              items: Schema.object(
                requiredProperties: ['text', 'completed'],
                properties: {
                  'text': Schema.string(),
                  'completed': Schema.boolean(),
                },
              ),
            ),
          },
        ),
      ),
    );

    try {
      final response = await model.generateContent([
        Content.multi([
          TextPart(_prompt),
          DataPart(mimeType, imageBytes),
        ]),
      ]);
      final responseText = response.text?.trim();
      if (responseText == null || responseText.isEmpty) {
        throw const GeminiScanException('Gemini returned an empty response.');
      }
      developer.log(
        'Gemini raw scan response: $responseText',
        name: 'NoteMind.GeminiVision',
      );
      return _parseResponse(responseText);
    } on GeminiScanException {
      rethrow;
    } catch (error) {
      developer.log(
        'Gemini scan request failed: ${error.runtimeType}',
        name: 'NoteMind.GeminiVision',
        error: error,
      );
      final message = error.toString().toLowerCase();
      if (message.contains('429') || message.contains('quota')) {
        throw const GeminiScanException(
          'Gemini is temporarily rate-limited. Please try again shortly.',
        );
      }
      if (message.contains('socket') ||
          message.contains('timeout') ||
          message.contains('network')) {
        throw const GeminiScanException(
          'Network error while contacting Gemini. Check your connection and try again.',
        );
      }
      throw const GeminiScanException(
        'Gemini could not analyze this image. Please try another image.',
      );
    }
  }

  ScannedChecklist _parseResponse(String responseText) {
    try {
      var normalizedResponse = responseText
          .replaceFirst('\ufeff', '')
          .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
          .replaceFirst(RegExp(r'\s*```$'), '')
          .trim();

      final firstObject = normalizedResponse.indexOf('{');
      final lastObject = normalizedResponse.lastIndexOf('}');
      if (firstObject >= 0 && lastObject > firstObject) {
        normalizedResponse = normalizedResponse.substring(
          firstObject,
          lastObject + 1,
        );
      }

      final decoded = jsonDecode(normalizedResponse);
      if (decoded is! Map) {
        throw const FormatException();
      }
      final response = Map<String, dynamic>.from(decoded);

      final title = response['title'];
      final rawItems = response['items'];
      if (title is! String || rawItems is! List) {
        throw const FormatException();
      }

      final items = <ChecklistItem>[];
      for (final rawItem in rawItems) {
        if (rawItem is! Map) {
          throw const FormatException();
        }
        final item = Map<String, dynamic>.from(rawItem);
        if (item['text'] is! String || item['completed'] is! bool) {
          throw const FormatException();
        }
        final text = (item['text'] as String).trim();
        if (text.isNotEmpty) {
          items.add(ChecklistItem(
            text: text,
            isDone: item['completed'] as bool,
          ));
        }
      }

      if (items.isEmpty) {
        throw const GeminiScanException(
          'No actionable checklist items were found in this image.',
        );
      }
      return ScannedChecklist(title: title.trim(), items: items);
    } on GeminiScanException {
      rethrow;
    } catch (error) {
      developer.log(
        'Gemini response parsing failed: ${error.runtimeType}',
        name: 'NoteMind.GeminiVision',
        error: error,
        stackTrace: StackTrace.current,
      );
      developer.log(
        'Gemini response received for parsing: $responseText',
        name: 'NoteMind.GeminiVision',
      );
      final preview = responseText
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      final shortenedPreview = preview.length > 160
          ? '${preview.substring(0, 160)}...'
          : preview;
      throw GeminiScanException(
        'Gemini returned an invalid checklist (${error.runtimeType}). '
        'Response preview: $shortenedPreview',
      );
    }
  }
}