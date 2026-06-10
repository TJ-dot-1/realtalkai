import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Configuration
/// Replace placeholder values with your actual API keys
class ApiConfig {
  ApiConfig._();

  // NOTE: For security and flexibility we read API keys and provider
  // selection from compile-time environment variables using
  // `--dart-define`. Example when running locally:
  //
  // flutter run --dart-define=API_PROVIDER=openai \
  //             --dart-define=OPENAI_API_KEY=sk-... \
  //
  // Or for Gemini (if you wire services to use Gemini):
  //
  // flutter run --dart-define=API_PROVIDER=gemini \
  //             --dart-define=GEMINI_API_KEY=ya29...

  // Provider selection: 'openai' or 'gemini' (defaults to 'openai')
  static String get apiProvider =>
      (dotenv.isInitialized ? dotenv.env['API_PROVIDER'] : null) ??
      const String.fromEnvironment('API_PROVIDER', defaultValue: 'openai');

  // OpenAI config (use .env OPENAI_API_KEY to override)
  // This is currently set to OpenRouter for text generation
  static String get openAiApiKey => 
      (dotenv.isInitialized ? dotenv.env['OPENAI_API_KEY'] : null) ?? 
      const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  
  static String get openAiBaseUrl => 
      (dotenv.isInitialized ? dotenv.env['OPENAI_BASE_URL'] : null) ?? 
      const String.fromEnvironment('OPENAI_BASE_URL', defaultValue: 'https://openrouter.ai/api/v1');

  // Audio config (OpenRouter does not support TTS/Whisper, so we use real OpenAI here)
  static String get audioApiKey => 
      (dotenv.isInitialized ? dotenv.env['AUDIO_API_KEY'] : null) ?? 
      const String.fromEnvironment('AUDIO_API_KEY', defaultValue: 'NO_AUDIO_KEY_PROVIDED');
  
  static String get audioBaseUrl => 
      (dotenv.isInitialized ? dotenv.env['AUDIO_BASE_URL'] : null) ?? 
      const String.fromEnvironment('AUDIO_BASE_URL', defaultValue: 'https://api.openai.com/v1');

  // Optional: Gemini config (use .env GEMINI_API_KEY)
  static String get geminiApiKey => 
      (dotenv.isInitialized ? dotenv.env['GEMINI_API_KEY'] : null) ?? 
      const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  
  static String get geminiBaseUrl => 
      (dotenv.isInitialized ? dotenv.env['GEMINI_BASE_URL'] : null) ?? 
      const String.fromEnvironment('GEMINI_BASE_URL', defaultValue: 'https://generative.googleapis.com/v1');

  // Models (can be overridden via .env if needed)
  static String get chatModel =>
      (dotenv.isInitialized ? dotenv.env['CHAT_MODEL'] : null) ?? 
      const String.fromEnvironment('CHAT_MODEL', defaultValue: 'gpt-5.4-mini');
  
  static String get feedbackModel =>
      (dotenv.isInitialized ? dotenv.env['FEEDBACK_MODEL'] : null) ?? 
      const String.fromEnvironment('FEEDBACK_MODEL', defaultValue: 'gpt-5.4-mini');
  
  static String get whisperModel =>
      (dotenv.isInitialized ? dotenv.env['WHISPER_MODEL'] : null) ?? 
      const String.fromEnvironment('WHISPER_MODEL', defaultValue: 'whisper-1');
  
  static String get ttsModel =>
      (dotenv.isInitialized ? dotenv.env['TTS_MODEL'] : null) ?? 
      const String.fromEnvironment('TTS_MODEL', defaultValue: 'tts-1');

  // TTS Voices mapped to characters (kept as constants but can be changed)
  static const String voiceFriendly = 'shimmer'; // Warm female voice
  static const String voiceStrict = 'onyx'; // Deep authoritative voice
  static const String voiceNeutral = 'echo'; // Balanced professional voice

  // ── Firebase ───────────────────────────────────────────────────
  // These are configured via google-services.json / GoogleService-Info.plist
  // No manual configuration needed here

  // ── App Settings ───────────────────────────────────────────────
  static const int maxConversationTurns = 20;
  static const int maxAudioDurationSeconds = 30;
  static const double chatTemperature = 0.8; // Higher = more creative
  static const double feedbackTemperature = 0.3; // Lower = more precise
}
