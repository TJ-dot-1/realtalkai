/// App-wide constants
class AppConstants {
  AppConstants._();

  // ── App Info ───────────────────────────────────────────────────
  static const String appName = 'RealTalk AI';
  static const String appTagline = 'Master Real Conversations';
  static const String appVersion = '1.0.0';

  // ── Route Names ────────────────────────────────────────────────
  static const String routeLogin = '/login';
  static const String routeHome = '/home';
  static const String routeScenarioSelect = '/scenario-select';
  static const String routeCharacterSelect = '/character-select';
  static const String routeConversation = '/conversation';
  static const String routeFeedback = '/feedback';

  // ── Animation Durations ────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration animVerySlow = Duration(milliseconds: 1000);

  // ── Conversation ───────────────────────────────────────────────
  static const int minMessagesForFeedback = 4;
  static const String systemRole = 'system';
  static const String userRole = 'user';
  static const String assistantRole = 'assistant';
}
