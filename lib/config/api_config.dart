/// API Configuration
/// Replace placeholder values with your actual API keys
class ApiConfig {
  ApiConfig._();

  // ── OpenAI ─────────────────────────────────────────────────────
  static const String openAiApiKey = 'YOUR_OPENAI_API_KEY_HERE';
  static const String openAiBaseUrl = 'https://api.openai.com/v1';

  // Models
  static const String chatModel = 'gpt-4o-mini'; // Fast + cheap for conversation
  static const String feedbackModel = 'gpt-4o';   // Higher quality for feedback
  static const String whisperModel = 'whisper-1';
  static const String ttsModel = 'tts-1';

  // TTS Voices mapped to characters
  static const String voiceFriendly = 'shimmer'; // Warm female voice
  static const String voiceStrict = 'onyx';      // Deep authoritative voice
  static const String voiceNeutral = 'echo';     // Balanced professional voice

  // ── Firebase ───────────────────────────────────────────────────
  // These are configured via google-services.json / GoogleService-Info.plist
  // No manual configuration needed here

  // ── App Settings ───────────────────────────────────────────────
  static const int maxConversationTurns = 20;
  static const int maxAudioDurationSeconds = 30;
  static const double chatTemperature = 0.8;    // Higher = more creative
  static const double feedbackTemperature = 0.3; // Lower = more precise
}
