import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'js_env.dart';

/// API Configuration
/// 
/// Environment variable priority (highest → lowest):
///   1. JavaScript injection via window._flutterEnv (Vercel runtime)
///   2. flutter_dotenv .env file (local development)
///   3. --dart-define compile-time constants (CI / manual builds)
class ApiConfig {
  ApiConfig._();

  /// Helper: resolve a config value through the 3-tier fallback chain.
  static String _resolve(String key, {String defaultValue = ''}) {
    // 1. JS env (Vercel serverless → window._flutterEnv)
    final jsValue = getJsEnv(key);
    if (jsValue != null && jsValue.isNotEmpty) return jsValue;

    // 2. dotenv (.env file loaded at startup)
    if (dotenv.isInitialized) {
      final dotenvValue = dotenv.env[key];
      if (dotenvValue != null && dotenvValue.isNotEmpty) return dotenvValue;
    }

    // 3. Compile-time --dart-define (returns '' if not set, so use defaultValue)
    final compileTime = String.fromEnvironment(key);
    if (compileTime.isNotEmpty) return compileTime;

    return defaultValue;
  }

  // Provider selection: 'openai' or 'gemini' (defaults to 'openai')
  static String get apiProvider => _resolve('API_PROVIDER', defaultValue: 'openai');

  // OpenAI config (use .env OPENAI_API_KEY to override)
  // This is currently set to OpenRouter for text generation
  static String get openAiApiKey => _resolve('OPENAI_API_KEY');
  
  static String get openAiBaseUrl =>
      _resolve('OPENAI_BASE_URL', defaultValue: 'https://openrouter.ai/api/v1');

  // Audio config (OpenRouter does not support TTS/Whisper, so we use real OpenAI here)
  static String get audioApiKey =>
      _resolve('AUDIO_API_KEY', defaultValue: 'NO_AUDIO_KEY_PROVIDED');
  
  static String get audioBaseUrl =>
      _resolve('AUDIO_BASE_URL', defaultValue: 'https://api.openai.com/v1');

  // Optional: Gemini config (use .env GEMINI_API_KEY)
  static String get geminiApiKey => _resolve('GEMINI_API_KEY');
  
  static String get geminiBaseUrl =>
      _resolve('GEMINI_BASE_URL', defaultValue: 'https://generative.googleapis.com/v1');

  // Models (can be overridden via .env if needed)
  static String get chatModel => _resolve('CHAT_MODEL', defaultValue: 'gpt-5.4-mini');
  
  static String get feedbackModel => _resolve('FEEDBACK_MODEL', defaultValue: 'gpt-5.4-mini');
  
  static String get whisperModel => _resolve('WHISPER_MODEL', defaultValue: 'whisper-1');
  
  static String get ttsModel => _resolve('TTS_MODEL', defaultValue: 'tts-1');

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
