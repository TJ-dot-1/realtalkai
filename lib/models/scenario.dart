/// Scenario model — represents a real-life conversation situation
class Scenario {
  final String id;
  final String title;
  final String description;
  final String goal;
  final String icon;
  final String difficulty;
  final String context;
  final List<String> sampleTopics;
  final String gradientStart;
  final String gradientEnd;

  const Scenario({
    required this.id,
    required this.title,
    required this.description,
    required this.goal,
    required this.icon,
    required this.difficulty,
    required this.context,
    required this.sampleTopics,
    required this.gradientStart,
    required this.gradientEnd,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'goal': goal,
    'difficulty': difficulty,
    'context': context,
  };

  // ── Predefined Scenarios ──────────────────────────────────────
  static const List<Scenario> all = [
    Scenario(
      id: 'job_interview',
      title: 'Job Interview',
      description: 'Practice answering tough interview questions with confidence and clarity.',
      goal: 'Get hired by impressing the interviewer',
      icon: '💼',
      difficulty: 'Hard',
      context: 'You are in a formal job interview at a top company. The interviewer is evaluating your communication skills, confidence, and ability to articulate your experience.',
      sampleTopics: ['Tell me about yourself', 'Why should we hire you?', 'Describe a challenge you overcame'],
      gradientStart: '0xFF6C63FF',
      gradientEnd: '0xFF00D9FF',
    ),
    Scenario(
      id: 'casual_chat',
      title: 'Casual Conversation',
      description: 'Practice making small talk and building natural connections.',
      goal: 'Build rapport and keep the conversation flowing',
      icon: '☕',
      difficulty: 'Easy',
      context: 'You are at a coffee shop and struck up a conversation with someone new. The atmosphere is relaxed and friendly.',
      sampleTopics: ['Hobbies', 'Travel', 'Weekend plans', 'Favorite movies'],
      gradientStart: '0xFF00E676',
      gradientEnd: '0xFF00D9FF',
    ),
    Scenario(
      id: 'business_meeting',
      title: 'Business Meeting',
      description: 'Practice presenting ideas and negotiating professionally.',
      goal: 'Present your proposal and close the deal',
      icon: '📊',
      difficulty: 'Medium',
      context: 'You are in a business meeting presenting a proposal to a potential client or partner. You need to be persuasive, clear, and professional.',
      sampleTopics: ['Project proposal', 'Budget discussion', 'Timeline negotiations'],
      gradientStart: '0xFFFF6B9D',
      gradientEnd: '0xFF6C63FF',
    ),
  ];
}
