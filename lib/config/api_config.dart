/// API Configuration for NoteMind
/// 
/// This file contains API keys and configuration settings.
/// 
/// IMPORTANT SECURITY NOTES:
/// 1. Never commit API keys to version control
/// 2. Add this file to .gitignore
/// 3. For production, use environment variables or secure storage
/// 4. Consider using Flutter's --dart-define for build-time configuration

class APIConfig {
  // Gemini API Configuration
  // Get your API key from: https://aistudio.google.com/app/apikey
   static const String geminiApiKey = 'AIzaSyC3rvDPCus3g_a2xgy3JQzlbpEHT9W_rDI';

  // Gemini API Settings
  static const String geminiModel = 'gemini-2.5-flash';
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  // Token limits
   static const int maxTokensPerRequest = 3000; // Supports longer Arabic checklists
  static const int maxInputTokens = 3000; // حدود الإدخال

  // API request settings
  static const double temperature = 0.7;
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Check if Gemini API is configured
  static bool get isGeminiConfigured =>
     geminiApiKey.isNotEmpty;

  /// Instructions for setting up API key
  static const String setupInstructions = '''
To use AI features in NoteMind:

1. Get a Gemini API key:
   - Visit https://aistudio.google.com/app/apikey
   - Sign up or log in to your Google account
   - Create a new API key
   - Copy the key

2. Add your API key directly to the geminiApiKey string above.

3. Security best practices:
   - Add api_config.dart to .gitignore
   - Never share your API key publicly
   - Monitor your API usage at https://aistudio.google.com/
   - Set usage limits if needed

4. Production security:
    - Production applications should call Gemini through a secure backend rather than
       exposing a permanent API key inside the APK.

Note: Gemini API offers free tier with limits. Check details at:
https://ai.google.dev/pricing
''';
}