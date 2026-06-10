import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../models/scenario.dart';
import '../models/character.dart';
import '../models/session.dart';
import '../services/openai_service.dart';
import '../services/firebase_service.dart';
import '../utils/prompt_builder.dart';

/// Conversation state
enum ConversationStatus {
  idle,
  recording,
  transcribing,
  thinking,
  speaking,
  error
}

class ConversationState {
  final ConversationStatus status;
  final List<Message> messages;
  final Session? session;
  final String? error;
  final String? currentTranscript; // Live transcript while recording
  final bool isSessionActive;

  const ConversationState({
    this.status = ConversationStatus.idle,
    this.messages = const [],
    this.session,
    this.error,
    this.currentTranscript,
    this.isSessionActive = false,
  });

  ConversationState copyWith({
    ConversationStatus? status,
    List<Message>? messages,
    Session? session,
    String? error,
    String? currentTranscript,
    bool? isSessionActive,
  }) {
    return ConversationState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      session: session ?? this.session,
      error: error ?? this.error,
      currentTranscript: currentTranscript ?? this.currentTranscript,
      isSessionActive: isSessionActive ?? this.isSessionActive,
    );
  }

  bool get isProcessing =>
      status == ConversationStatus.recording ||
      status == ConversationStatus.transcribing ||
      status == ConversationStatus.thinking ||
      status == ConversationStatus.speaking;

  /// Non-system messages for display
  List<Message> get displayMessages =>
      messages.where((m) => !m.isSystem).toList();

  int get userMessageCount => messages.where((m) => m.isUser).length;
}

class ConversationNotifier extends StateNotifier<ConversationState> {
  // ignore: unused_field
  late Character _character;

  ConversationNotifier() : super(const ConversationState());

  /// Initialize a new conversation session
  void startSession(Scenario scenario, Character character, String userId) {
    // Store for potential future use
    _character = character;

    // Build system prompt
    final systemPrompt = PromptBuilder.buildSystemPrompt(
      scenario: scenario,
      character: character,
    );

    // Create opening message
    final openingMessage = PromptBuilder.buildOpeningMessage(
      scenario: scenario,
      character: character,
    );

    final session = Session(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      scenarioId: scenario.id,
      characterId: character.id,
      startedAt: DateTime.now(),
    );

    state = ConversationState(
      status: ConversationStatus.idle,
      messages: [
        Message.system(systemPrompt),
        Message.assistant(openingMessage),
      ],
      session: session,
      isSessionActive: true,
    );
  }



  /// Handle text input
  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;
    await _processUserInput(text.trim(), isVoice: false);
  }

  /// Core processing pipeline: User Input → AI Response → TTS
  Future<void> _processUserInput(String text, {required bool isVoice}) async {
    // Add user message
    final userMessage = Message.user(text, isVoice: isVoice);
    final updatedMessages = [...state.messages, userMessage];
    state = state.copyWith(
      messages: updatedMessages,
      status: ConversationStatus.thinking,
      currentTranscript: null,
    );

    try {
      // Step 2: Get AI response
      final aiResponse = await OpenAIService.getChatResponse(updatedMessages);

      // Add AI message
      final aiMessage = Message.assistant(aiResponse);
      final allMessages = [...updatedMessages, aiMessage];
      state = state.copyWith(
        messages: allMessages,
        status: ConversationStatus.idle,
      );
    } catch (e) {
      state = state.copyWith(
        status: ConversationStatus.error,
        error: 'Failed to get response: $e',
      );
    }
  }



  /// End the conversation session
  Future<Session> endSession() async {
    final session = state.session?.copyWith(
      endedAt: DateTime.now(),
      messages: state.messages,
    );

    state = state.copyWith(
      isSessionActive: false,
      status: ConversationStatus.idle,
    );

    // Save session to Firestore
    if (session != null) {
      await FirestoreService.saveSession(session.toMap());
    }

    return session!;
  }

  /// Clear any error
  void clearError() {
    state = state.copyWith(
      status: ConversationStatus.idle,
      error: null,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

final conversationProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  return ConversationNotifier();
});
