import 'message.dart';

/// Conversation session model
class Session {
  final String id;
  final String userId;
  final String scenarioId;
  final String characterId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<Message> messages;
  final bool feedbackGenerated;

  const Session({
    required this.id,
    required this.userId,
    required this.scenarioId,
    required this.characterId,
    required this.startedAt,
    this.endedAt,
    this.messages = const [],
    this.feedbackGenerated = false,
  });

  Session copyWith({
    DateTime? endedAt,
    List<Message>? messages,
    bool? feedbackGenerated,
  }) {
    return Session(
      id: id,
      userId: userId,
      scenarioId: scenarioId,
      characterId: characterId,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      messages: messages ?? this.messages,
      feedbackGenerated: feedbackGenerated ?? this.feedbackGenerated,
    );
  }

  /// Duration of the session
  Duration get duration {
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  /// Number of user messages
  int get userMessageCount => messages.where((m) => m.isUser).length;

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'scenarioId': scenarioId,
    'characterId': characterId,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'messages': messages.map((m) => m.toMap()).toList(),
    'feedbackGenerated': feedbackGenerated,
  };
}
