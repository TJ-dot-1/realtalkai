import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feedback_result.dart';
import '../models/message.dart';
import '../services/openai_service.dart';
import '../services/firebase_service.dart';

/// Feedback generation state
enum FeedbackStatus { idle, generating, done, error }

class FeedbackState {
  final FeedbackStatus status;
  final FeedbackResult? result;
  final String? error;

  const FeedbackState({
    this.status = FeedbackStatus.idle,
    this.result,
    this.error,
  });

  FeedbackState copyWith({
    FeedbackStatus? status,
    FeedbackResult? result,
    String? error,
  }) {
    return FeedbackState(
      status: status ?? this.status,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

class FeedbackNotifier extends StateNotifier<FeedbackState> {
  FeedbackNotifier() : super(const FeedbackState());

  /// Generate feedback from conversation messages
  Future<void> generateFeedback({
    required String sessionId,
    required List<Message> messages,
    required String scenarioContext,
    required String characterName,
  }) async {
    state = const FeedbackState(status: FeedbackStatus.generating);

    try {
      final result = await OpenAIService.generateFeedback(
        sessionId: sessionId,
        messages: messages,
        scenarioContext: scenarioContext,
        characterName: characterName,
      );

      // Save to Firestore
      await FirestoreService.saveFeedback(sessionId, result.toMap());

      state = FeedbackState(
        status: FeedbackStatus.done,
        result: result,
      );
    } catch (e) {
      state = FeedbackState(
        status: FeedbackStatus.error,
        error: 'Failed to generate feedback: $e',
      );
    }
  }

  /// Reset feedback state
  void reset() {
    state = const FeedbackState();
  }
}

final feedbackProvider =
    StateNotifierProvider<FeedbackNotifier, FeedbackState>((ref) {
  return FeedbackNotifier();
});
