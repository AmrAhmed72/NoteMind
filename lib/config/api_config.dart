class APIConfig {
  // Gemini API Configuration
  // Get your API key from: https://aistudio.google.com/app/apikey
   // Development only. For production, keep Gemini behind a secure backend.
   static const String geminiApiKey =
         String.fromEnvironment('GEMINI_API_KEY');

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

2. Add your own key when running locally:
   flutter run --dart-define=GEMINI_API_KEY=your_key_here

3. Security best practices:
   - Never put an API key directly in this source file
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