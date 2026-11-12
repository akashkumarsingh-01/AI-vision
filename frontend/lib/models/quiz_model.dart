class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
}

class QuizSession {
  final String id;
  final String topic;
  final String difficulty;
  final List<QuizQuestion> questions;

  QuizSession({
    required this.id,
    required this.topic,
    required this.difficulty,
    required this.questions,
  });

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    var rawQ = json['questions'] as List? ?? [];
    return QuizSession(
      id: json['id'] ?? '',
      topic: json['topic'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      questions: rawQ.map((q) => QuizQuestion.fromJson(Map<String, dynamic>.from(q))).toList(),
    );
  }
}

class QuizEvaluationResult {
  final String id;
  final String quizId;
  final String topic;
  final String difficulty;
  final int totalQuestions;
  final int correctCount;
  final int scorePercent;
  final List<dynamic> breakdown;
  final DateTime timestamp;

  QuizEvaluationResult({
    required this.id,
    required this.quizId,
    required this.topic,
    required this.difficulty,
    required this.totalQuestions,
    required this.correctCount,
    required this.scorePercent,
    required this.breakdown,
    required this.timestamp,
  });

  factory QuizEvaluationResult.fromJson(Map<String, dynamic> json) {
    return QuizEvaluationResult(
      id: json['id'] ?? '',
      quizId: json['quizId'] ?? '',
      topic: json['topic'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      totalQuestions: json['totalQuestions'] ?? 0,
      correctCount: json['correctCount'] ?? 0,
      scorePercent: json['scorePercent'] ?? 0,
      breakdown: json['breakdown'] ?? [],
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

