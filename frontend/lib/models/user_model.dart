class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String bio;
  final List<String> learningGoals;
  final Map<String, dynamic> preferences;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.bio,
    this.learningGoals = const [],
    this.preferences = const {},
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Vision User',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? 'https://api.dicebear.com/7.x/bottts/svg?seed=VisionUser',
      bio: json['bio'] ?? '',
      learningGoals: List<String>.from(json['learningGoals'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar': avatar,
    'bio': bio,
    'learningGoals': learningGoals,
    'preferences': preferences,
  };
}

class UserStats {
  final int conversationsCount;
  final int quizzesTaken;
  final int avgQuizScore;
  final int coursesCompleted;
  final int totalLessonsFinished;

  UserStats({
    this.conversationsCount = 0,
    this.quizzesTaken = 0,
    this.avgQuizScore = 0,
    this.coursesCompleted = 0,
    this.totalLessonsFinished = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      conversationsCount: json['conversationsCount'] ?? 0,
      quizzesTaken: json['quizzesTaken'] ?? 0,
      avgQuizScore: json['avgQuizScore'] ?? 0,
      coursesCompleted: json['coursesCompleted'] ?? 0,
      totalLessonsFinished: json['totalLessonsFinished'] ?? 0,
    );
  }
}

