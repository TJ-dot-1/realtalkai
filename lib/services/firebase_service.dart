import '../models/user_progress.dart';

/// Firebase Auth service (placeholder — works without Firebase for now)
/// Replace with actual Firebase Auth when Firebase is configured
class AuthService {
  static String? _currentUserId;
  static String? _currentEmail;
  static String? _currentDisplayName;

  static bool get isLoggedIn => _currentUserId != null;
  static String? get currentUserId => _currentUserId;
  static String? get currentEmail => _currentEmail;
  static String? get currentDisplayName => _currentDisplayName;

  /// Sign in with email and password (placeholder)
  static Future<bool> signInWithEmail(String email, String password) async {
    // TODO: Replace with Firebase Auth
    // await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
    _currentUserId = 'user_${email.hashCode}';
    _currentEmail = email;
    _currentDisplayName = email.split('@').first;
    return true;
  }

  /// Sign up with email and password (placeholder)
  static Future<bool> signUpWithEmail(String email, String password, String name) async {
    // TODO: Replace with Firebase Auth
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUserId = 'user_${email.hashCode}';
    _currentEmail = email;
    _currentDisplayName = name;
    return true;
  }

  /// Sign in with Google (placeholder)
  static Future<bool> signInWithGoogle() async {
    // TODO: Replace with Firebase Auth + Google Sign-In
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUserId = 'user_google_123';
    _currentEmail = 'user@gmail.com';
    _currentDisplayName = 'RealTalk User';
    return true;
  }

  /// Sign out
  static Future<void> signOut() async {
    // TODO: Replace with Firebase Auth
    _currentUserId = null;
    _currentEmail = null;
    _currentDisplayName = null;
  }
}

/// Firestore service (placeholder — stores in memory for now)
/// Replace with actual Firestore when Firebase is configured
class FirestoreService {
  // In-memory storage (replace with Firestore)
  static final Map<String, Map<String, dynamic>> _sessions = {};
  static final Map<String, Map<String, dynamic>> _feedback = {};
  static UserProgress _progress = UserProgress.empty('');

  /// Save a session
  static Future<void> saveSession(Map<String, dynamic> session) async {
    // TODO: Replace with Firestore
    // await FirebaseFirestore.instance.collection('sessions').doc(session['id']).set(session);
    _sessions[session['id'] as String] = session;
  }

  /// Save feedback
  static Future<void> saveFeedback(String sessionId, Map<String, dynamic> feedback) async {
    // TODO: Replace with Firestore
    _feedback[sessionId] = feedback;
  }

  /// Get user progress
  static Future<UserProgress> getProgress(String userId) async {
    // TODO: Replace with Firestore
    if (_progress.userId.isEmpty) {
      _progress = UserProgress.empty(userId);
    }
    return _progress;
  }

  /// Update user progress
  static Future<void> updateProgress(UserProgress progress) async {
    // TODO: Replace with Firestore
    _progress = progress;
  }

  /// Get recent sessions
  static Future<List<Map<String, dynamic>>> getRecentSessions(String userId, {int limit = 5}) async {
    // TODO: Replace with Firestore query
    return _sessions.values
        .where((s) => s['userId'] == userId)
        .take(limit)
        .toList();
  }
}
