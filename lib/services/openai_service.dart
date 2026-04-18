import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/message.dart';
import '../models/feedback_result.dart';

/// OpenAI Chat API service — handles conversation and feedback generation
class OpenAIService {
  static const _headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${ApiConfig.openAiApiKey}',
  };

  /// Send a conversation message and get AI response
  /// [messages] should include the system prompt as the first message
  static Future<String> getChatResponse(List<Message> messages) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.openAiBaseUrl}/chat/completions'),
        headers: _headers,
        body: jsonEncode({
          'model': ApiConfig.chatModel,
          'messages': messages.map((m) => m.toOpenAiFormat()).toList(),
          'temperature': ApiConfig.chatTemperature,
          'max_tokens': 200, // Keep responses concise
          'presence_penalty': 0.6, // Reduce repetition
          'frequency_penalty': 0.3, // Encourage vocabulary variety
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get chat response: $e');
    }
  }

  /// Generate post-session feedback by analyzing the conversation
  static Future<FeedbackResult> generateFeedback({
    required String sessionId,
    required List<Message> messages,
    required String scenarioContext,
    required String characterName,
  }) async {
    // Build the conversation transcript
    final transcript = messages
        .where((m) => !m.isSystem)
        .map((m) => '${m.isUser ? "LEARNER" : characterName.toUpperCase()}: ${m.content}')
        .join('\n');

    final feedbackPrompt = '''Analyze this English conversation between a language learner and an AI character named $characterName.

SCENARIO CONTEXT: $scenarioContext

CONVERSATION TRANSCRIPT:
$transcript

Provide a detailed analysis as a JSON object with this exact structure:
{
  "confidenceScore": <0-100 integer>,
  "fluencyScore": <0-100 integer>,
  "grammarCorrections": [
    {"original": "<exact text with error>", "corrected": "<corrected version>", "explanation": "<brief rule explanation>"}
  ],
  "improvedResponses": [
    {"userSaid": "<what user said>", "betterWay": "<improved version>", "why": "<brief explanation>"}
  ],
  "strengths": ["<strength 1>", "<strength 2>"],
  "areasToImprove": ["<area 1>", "<area 2>"],
  "overallFeedback": "<2-3 sentence personalized summary>"
}

SCORING GUIDELINES:
- confidenceScore: How confidently the learner communicated (hesitation, clarity, directness)
- fluencyScore: Overall language quality (grammar, vocabulary, natural flow)
- Focus on the top 3-5 most important issues only
- Be specific with examples from the actual conversation
- Be encouraging but honest

Respond with ONLY the JSON object, no markdown formatting.''';

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.openAiBaseUrl}/chat/completions'),
        headers: _headers,
        body: jsonEncode({
          'model': ApiConfig.feedbackModel,
          'messages': [
            {'role': 'system', 'content': 'You are an expert English language coach. Analyze conversations and provide actionable feedback.'},
            {'role': 'user', 'content': feedbackPrompt},
          ],
          'temperature': ApiConfig.feedbackTemperature,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        // Parse JSON from response (handle potential markdown wrapping)
        String jsonStr = content.trim();
        if (jsonStr.startsWith('```')) {
          jsonStr = jsonStr.substring(jsonStr.indexOf('{'), jsonStr.lastIndexOf('}') + 1);
        }

        final feedbackJson = jsonDecode(jsonStr) as Map<String, dynamic>;
        return FeedbackResult.fromJson(feedbackJson, sessionId);
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      // Return a default feedback if parsing fails
      return FeedbackResult(
        sessionId: sessionId,
        confidenceScore: 50,
        fluencyScore: 50,
        grammarCorrections: [],
        improvedResponses: [],
        strengths: ['Completed the conversation'],
        areasToImprove: ['Keep practicing for more detailed feedback'],
        overallFeedback: 'Unable to generate detailed feedback. Please try again.',
      );
    }
  }
}
