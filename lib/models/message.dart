/// Chat message model
class Message {
  final String id;
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final DateTime timestamp;
  final bool isVoiceInput;

  const Message({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isVoiceInput = false,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get isSystem => role == 'system';

  Map<String, dynamic> toMap() => {
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'isVoiceInput': isVoiceInput,
  };

  /// Convert to OpenAI message format
  Map<String, String> toOpenAiFormat() => {
    'role': role,
    'content': content,
  };

  factory Message.user(String content, {String? id, bool isVoice = false}) {
    return Message(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
      isVoiceInput: isVoice,
    );
  }

  factory Message.assistant(String content, {String? id}) {
    return Message(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'assistant',
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory Message.system(String content) {
    return Message(
      id: 'system',
      role: 'system',
      content: content,
      timestamp: DateTime.now(),
    );
  }
}
