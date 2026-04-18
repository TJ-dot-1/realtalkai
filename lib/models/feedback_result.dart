/// Post-session feedback result from AI analysis
class FeedbackResult {
  final String sessionId;
  final int confidenceScore;
  final int fluencyScore;
  final List<GrammarCorrection> grammarCorrections;
  final List<ImprovedResponse> improvedResponses;
  final List<String> strengths;
  final List<String> areasToImprove;
  final String overallFeedback;

  const FeedbackResult({
    required this.sessionId,
    required this.confidenceScore,
    required this.fluencyScore,
    required this.grammarCorrections,
    required this.improvedResponses,
    required this.strengths,
    required this.areasToImprove,
    required this.overallFeedback,
  });

  factory FeedbackResult.fromJson(Map<String, dynamic> json, String sessionId) {
    return FeedbackResult(
      sessionId: sessionId,
      confidenceScore: (json['confidenceScore'] as num?)?.toInt() ?? 0,
      fluencyScore: (json['fluencyScore'] as num?)?.toInt() ?? 0,
      grammarCorrections: (json['grammarCorrections'] as List<dynamic>?)
          ?.map((e) => GrammarCorrection.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      improvedResponses: (json['improvedResponses'] as List<dynamic>?)
          ?.map((e) => ImprovedResponse.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      strengths: (json['strengths'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      areasToImprove: (json['areasToImprove'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      overallFeedback: json['overallFeedback'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'sessionId': sessionId,
    'confidenceScore': confidenceScore,
    'fluencyScore': fluencyScore,
    'grammarCorrections': grammarCorrections.map((e) => e.toMap()).toList(),
    'improvedResponses': improvedResponses.map((e) => e.toMap()).toList(),
    'strengths': strengths,
    'areasToImprove': areasToImprove,
    'overallFeedback': overallFeedback,
  };
}

class GrammarCorrection {
  final String original;
  final String corrected;
  final String explanation;

  const GrammarCorrection({
    required this.original,
    required this.corrected,
    required this.explanation,
  });

  factory GrammarCorrection.fromJson(Map<String, dynamic> json) {
    return GrammarCorrection(
      original: json['original'] as String? ?? '',
      corrected: json['corrected'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'original': original,
    'corrected': corrected,
    'explanation': explanation,
  };
}

class ImprovedResponse {
  final String userSaid;
  final String betterWay;
  final String why;

  const ImprovedResponse({
    required this.userSaid,
    required this.betterWay,
    required this.why,
  });

  factory ImprovedResponse.fromJson(Map<String, dynamic> json) {
    return ImprovedResponse(
      userSaid: json['userSaid'] as String? ?? '',
      betterWay: json['betterWay'] as String? ?? '',
      why: json['why'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'userSaid': userSaid,
    'betterWay': betterWay,
    'why': why,
  };
}
