class EnvConfig {
  /// Gemini API Key defined via --dart-define or --dart-define-from-file
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Checks if the API key is configured
  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
}
