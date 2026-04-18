/// User progress tracking model
class UserProgress {
  final String userId;
  final List<int> fluencyScores;
  final int sessionsCompleted;
  final Map<String, ScenarioProgress> scenarioProgress;
  final int streak;
  final DateTime? lastSessionDate;

  const UserProgress({
    required this.userId,
    this.fluencyScores = const [],
    this.sessionsCompleted = 0,
    this.scenarioProgress = const {},
    this.streak = 0,
    this.lastSessionDate,
  });

  /// Average fluency score
  double get averageFluency {
    if (fluencyScores.isEmpty) return 0;
    return fluencyScores.reduce((a, b) => a + b) / fluencyScores.length;
  }

  /// Latest fluency score
  int get latestFluency => fluencyScores.isEmpty ? 0 : fluencyScores.last;

  /// Fluency trend (positive = improving)
  int get fluencyTrend {
    if (fluencyScores.length < 2) return 0;
    return fluencyScores.last - fluencyScores[fluencyScores.length - 2];
  }

  UserProgress copyWith({
    List<int>? fluencyScores,
    int? sessionsCompleted,
    Map<String, ScenarioProgress>? scenarioProgress,
    int? streak,
    DateTime? lastSessionDate,
  }) {
    return UserProgress(
      userId: userId,
      fluencyScores: fluencyScores ?? this.fluencyScores,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      scenarioProgress: scenarioProgress ?? this.scenarioProgress,
      streak: streak ?? this.streak,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'fluencyScores': fluencyScores,
    'sessionsCompleted': sessionsCompleted,
    'scenarioProgress': scenarioProgress.map((k, v) => MapEntry(k, v.toMap())),
    'streak': streak,
    'lastSessionDate': lastSessionDate?.toIso8601String(),
  };

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['userId'] as String? ?? '',
      fluencyScores: (map['fluencyScores'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ?? [],
      sessionsCompleted: map['sessionsCompleted'] as int? ?? 0,
      scenarioProgress: (map['scenarioProgress'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, ScenarioProgress.fromMap(v as Map<String, dynamic>))) ?? {},
      streak: map['streak'] as int? ?? 0,
      lastSessionDate: map['lastSessionDate'] != null
          ? DateTime.parse(map['lastSessionDate'] as String)
          : null,
    );
  }

  factory UserProgress.empty(String userId) => UserProgress(userId: userId);
}

class ScenarioProgress {
  final int completed;
  final int bestScore;

  const ScenarioProgress({
    this.completed = 0,
    this.bestScore = 0,
  });

  Map<String, dynamic> toMap() => {
    'completed': completed,
    'bestScore': bestScore,
  };

  factory ScenarioProgress.fromMap(Map<String, dynamic> map) {
    return ScenarioProgress(
      completed: map['completed'] as int? ?? 0,
      bestScore: map['bestScore'] as int? ?? 0,
    );
  }
}
