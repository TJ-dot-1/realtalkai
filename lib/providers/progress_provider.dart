import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_progress.dart';
import '../services/firebase_service.dart';

/// Progress state
class ProgressState {
  final UserProgress progress;
  final bool isLoading;

  const ProgressState({
    required this.progress,
    this.isLoading = false,
  });

  ProgressState copyWith({
    UserProgress? progress,
    bool? isLoading,
  }) {
    return ProgressState(
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  ProgressNotifier() : super(ProgressState(progress: UserProgress.empty('')));

  /// Load user progress from Firestore
  Future<void> loadProgress(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final progress = await FirestoreService.getProgress(userId);
      state = ProgressState(progress: progress);
    } catch (e) {
      state = ProgressState(progress: UserProgress.empty(userId));
    }
  }

  /// Update progress after a session
  Future<void> recordSession({
    required String scenarioId,
    required int fluencyScore,
  }) async {
    final current = state.progress;
    
    // Update scenario progress
    final scenarioProgress = Map<String, ScenarioProgress>.from(current.scenarioProgress);
    final existing = scenarioProgress[scenarioId] ?? const ScenarioProgress();
    scenarioProgress[scenarioId] = ScenarioProgress(
      completed: existing.completed + 1,
      bestScore: fluencyScore > existing.bestScore ? fluencyScore : existing.bestScore,
    );

    // Calculate streak
    final now = DateTime.now();
    final lastSession = current.lastSessionDate;
    int newStreak = current.streak;
    if (lastSession != null) {
      final daysDiff = now.difference(lastSession).inDays;
      if (daysDiff <= 1) {
        newStreak = current.streak + 1;
      } else {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    final updated = current.copyWith(
      fluencyScores: [...current.fluencyScores, fluencyScore],
      sessionsCompleted: current.sessionsCompleted + 1,
      scenarioProgress: scenarioProgress,
      streak: newStreak,
      lastSessionDate: now,
    );

    state = ProgressState(progress: updated);
    await FirestoreService.updateProgress(updated);
  }
}

final progressProvider =
    StateNotifierProvider<ProgressNotifier, ProgressState>((ref) {
  return ProgressNotifier();
});
