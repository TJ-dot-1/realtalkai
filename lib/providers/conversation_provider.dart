import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../models/scenario.dart';
import '../models/character.dart';
import '../models/session.dart';
import '../services/openai_service.dart';
import '../services/speech_service.dart';
import '../services/audio_service.dart';
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
  final AudioService _audioService = AudioService();
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

    // Play opening message via TTS
    _speakMessage(openingMessage);
  }

  /// Handle voice input — start recording
  Future<void> startRecording() async {
    try {
      final hasPermission = await _audioService.hasPermission();
      if (!hasPermission) {
        state = state.copyWith(
          status: ConversationStatus.error,
          error: 'Microphone permission required',
        );
        return;
      }

      await _audioService.startRecording();
      state = state.copyWith(status: ConversationStatus.recording);
    } catch (e) {
      state = state.copyWith(
        status: ConversationStatus.error,
        error: 'Failed to start recording: $e',
      );
    }
  }

  /// Stop recording and process voice input
  Future<void> stopRecording() async {
    try {
      final audioPath = await _audioService.stopRecording();
      if (audioPath == null) {
        state = state.copyWith(status: ConversationStatus.idle);
        return;
      }

      // Step 1: Transcribe
      state = state.copyWith(status: ConversationStatus.transcribing);
      final transcript = await SpeechToTextService.transcribe(audioPath);

      if (transcript.isEmpty) {
        state = state.copyWith(
          status: ConversationStatus.idle,
          error: 'Could not understand audio. Please try again.',
        );
        return;
      }

      // Process the transcribed text
      await _processUserInput(transcript, isVoice: true);

      // Clean up audio file
      await AudioService.cleanupFile(audioPath);
    } catch (e) {
      state = state.copyWith(
        status: ConversationStatus.error,
        error: 'Voice processing failed: $e',
      );
    }
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
        status: ConversationStatus.speaking,
      );

      // Step 3: Speak the response
      await _speakMessage(aiResponse);

      state = state.copyWith(status: ConversationStatus.idle);
    } catch (e) {
      state = state.copyWith(
        status: ConversationStatus.error,
        error: 'Failed to get response: $e',
      );
    }
  }

  /// Play AI response via TTS
  Future<void> _speakMessage(String text) async {
    try {
      final audioPath = await TextToSpeechService.synthesize(
        text,
        voice: _character.ttsVoice,
      );
      await _audioService.playAudio(audioPath);
      // Wait for audio to finish (approximate)
      await Future.delayed(Duration(milliseconds: text.length * 60));
      await AudioService.cleanupFile(audioPath);
    } catch (e) {
      // TTS failure is non-critical in most cases — log and surface quota issues
      debugPrint('TTS failed: $e');
      final errMsg = e.toString();
      if (errMsg.contains('insufficient quota') ||
          errMsg.contains('insufficient_quota')) {
        state = state.copyWith(
          status: ConversationStatus.error,
          error:
              'Text-to-speech quota exhausted. Check your OpenAI plan/billing at https://platform.openai.com/account/usage',
        );
      }
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

    await _audioService.dispose();
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
    _audioService.dispose();
    super.dispose();
  }
}

final conversationProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  return ConversationNotifier();
});
