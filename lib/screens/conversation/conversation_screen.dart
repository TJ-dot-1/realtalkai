import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scenario_provider.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/feedback_provider.dart';
import '../../widgets/conversation/chat_bubble.dart';
import '../../widgets/conversation/typing_indicator.dart';

/// Core conversation screen — voice + text chat UI
class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize conversation session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scenario = ref.read(selectedScenarioProvider);
      final character = ref.read(selectedCharacterProvider);
      final userId = ref.read(authProvider).userId ?? 'anonymous';

      if (scenario != null && character != null) {
        ref.read(conversationProvider.notifier).startSession(
              scenario,
              character,
              userId,
            );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(conversationProvider);
    final scenario = ref.watch(selectedScenarioProvider);
    final character = ref.watch(selectedCharacterProvider);

    // Auto-scroll on new messages
    ref.listen<ConversationState>(conversationProvider, (prev, next) {
      if ((prev?.messages.length ?? 0) != next.messages.length) {
        _scrollToBottom();
      }
    });

    final String statusText;
    switch (conversation.status) {
      case ConversationStatus.idle:
        statusText = 'Tap to speak';
        break;
      case ConversationStatus.recording:
        statusText = '🔴 Listening...';
        break;
      case ConversationStatus.transcribing:
        statusText = 'Transcribing...';
        break;
      case ConversationStatus.thinking:
        statusText = '${character?.name ?? "AI"} is thinking...';
        break;
      case ConversationStatus.speaking:
        statusText = '${character?.name ?? "AI"} is speaking...';
        break;
      case ConversationStatus.error:
        statusText = 'Error occurred';
        break;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar — scenario + character info + end button
              _buildTopBar(scenario, character, conversation),
              // Chat messages
              Expanded(
                child: _buildMessageList(conversation, character),
              ),
              // Error banner
              if (conversation.error != null)
                _buildErrorBanner(conversation.error!),
              // Input area
              _buildInputArea(conversation, statusText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(scenario, character, ConversationState conversation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: AppTheme.cardBorder.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          // Back / End
          GestureDetector(
            onTap: () => _showEndDialog(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Scenario + Character info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (scenario != null)
                  Text(
                    '${scenario.icon} ${scenario.title}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                if (character != null)
                  Text(
                    'with ${character.name} (${character.type})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          // Message count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${conversation.userMessageCount} msgs',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // End session button
          GestureDetector(
            onTap: conversation.userMessageCount >= 2
                ? () => _endSession()
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: conversation.userMessageCount >= 2
                    ? AppTheme.accent.withOpacity(0.1)
                    : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: conversation.userMessageCount >= 2
                      ? AppTheme.accent.withOpacity(0.3)
                      : Colors.transparent,
                ),
              ),
              child: Text(
                'End',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: conversation.userMessageCount >= 2
                      ? AppTheme.accent
                      : AppTheme.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ConversationState conversation, character) {
    final messages = conversation.displayMessages;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length + (conversation.status == ConversationStatus.thinking ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          // Typing indicator
          return const TypingIndicator(label: 'thinking');
        }

        final message = messages[index];
        return ChatBubble(
          message: message.content,
          isUser: message.isUser,
          isVoice: message.isVoiceInput,
          characterEmoji: character?.emoji,
        );
      },
    );
  }

  Widget _buildErrorBanner(String error) {
    return GestureDetector(
      onTap: () => ref.read(conversationProvider.notifier).clearError(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: AppTheme.error.withOpacity(0.1),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(
                  color: AppTheme.error,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.close, color: AppTheme.error, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ConversationState conversation, String statusText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.8),
        border: Border(
          top: BorderSide(color: AppTheme.cardBorder.withOpacity(0.3)),
        ),
      ),
      child: Column(
        children: [
          // Text input
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      filled: true,
                      fillColor: AppTheme.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 15),
                    onSubmitted: (_) => _sendText(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendText,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    ref.read(conversationProvider.notifier).sendTextMessage(text);
    _textController.clear();
  }

  void _showEndDialog() {
    final conversation = ref.read(conversationProvider);
    if (conversation.userMessageCount < 2) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: const Text(
          'End Conversation?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Would you like to end this session and get your feedback?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _endSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Get Feedback'),
          ),
        ],
      ),
    );
  }

  Future<void> _endSession() async {
    final conversation = ref.read(conversationProvider);
    final scenario = ref.read(selectedScenarioProvider);
    final character = ref.read(selectedCharacterProvider);

    // End session
    final session =
        await ref.read(conversationProvider.notifier).endSession();

    // Generate feedback
    ref.read(feedbackProvider.notifier).generateFeedback(
          sessionId: session.id,
          messages: conversation.messages,
          scenarioContext: scenario?.context ?? '',
          characterName: character?.name ?? 'AI',
        );

    // Navigate to feedback screen
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppConstants.routeFeedback);
    }
  }
}
