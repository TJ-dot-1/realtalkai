import '../models/scenario.dart';
import '../models/character.dart';
import '../models/message.dart';

/// Builds dynamic AI prompts based on scenario + character + conversation context
class PromptBuilder {
  /// Build the system prompt for a conversation
  static String buildSystemPrompt({
    required Scenario scenario,
    required Character character,
  }) {
    return '''${character.systemPrompt}

CURRENT SCENARIO: ${scenario.title}
SCENARIO CONTEXT: ${scenario.context}
USER'S GOAL: ${scenario.goal}

ADDITIONAL INSTRUCTIONS:
- You are in a ${scenario.title.toLowerCase()} scenario
- Adapt your difficulty based on the user's responses
- If the user gives short/simple responses, keep your questions accessible
- If the user communicates well, increase the challenge
- Keep the conversation natural and evolving
- Never break character or reveal you are an AI
- Maximum 1-3 sentences per response
- Drive the conversation forward with each response''';
  }

  /// Build the opening message for a conversation
  static String buildOpeningMessage({
    required Scenario scenario,
    required Character character,
  }) {
    switch (scenario.id) {
      case 'job_interview':
        switch (character.id) {
          case 'friendly':
            return "Hi there! Welcome, please have a seat. I'm Sara, and I'll be conducting your interview today. Don't worry, just be yourself! So, tell me — what made you interested in this position?";
          case 'strict':
            return "Sit down. I'm Marcus. I have 15 minutes. Let's not waste time. Why should I hire you?";
          case 'neutral':
            return "Good morning. I'm Alex from the hiring team. Thank you for coming in today. Let's start — could you briefly walk me through your background?";
          default:
            return "Welcome to your interview. Let's begin.";
        }

      case 'casual_chat':
        switch (character.id) {
          case 'friendly':
            return "Hey! Is this seat taken? I love this coffee shop — I come here all the time! I'm Sara, by the way. What's your name?";
          case 'strict':
            return "Morning. I see you're sitting alone. Mind if I ask — what are you working on there?";
          case 'neutral':
            return "Hello. Nice place, isn't it? I'm Alex. Do you come here often?";
          default:
            return "Hi there. Mind if we chat?";
        }

      case 'business_meeting':
        switch (character.id) {
          case 'friendly':
            return "Great to finally meet in person! I'm Sara from the partnerships team. I've been really excited to hear about your proposal. Please, go ahead whenever you're ready!";
          case 'strict':
            return "Let's get started. I'm Marcus, VP of Operations. I've reviewed your preliminary materials. I have concerns. Convince me this is worth our investment.";
          case 'neutral':
            return "Good afternoon. I'm Alex, the project lead. Thank you for preparing this presentation. Please begin with an overview of your proposal.";
          default:
            return "Welcome to the meeting. Please present your proposal.";
        }

      default:
        return "Hello! Let's start our conversation.";
    }
  }

  /// Build a summarized context from conversation history
  /// Used to keep token count manageable for long conversations
  static String buildContextSummary(List<Message> messages) {
    if (messages.length <= 6) return '';

    final recentMessages = messages.skip(messages.length - 6);
    return 'RECENT CONVERSATION CONTEXT:\n' +
        recentMessages
            .map((m) => '${m.role}: ${m.content}')
            .join('\n');
  }
}
