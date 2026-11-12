class CourseModule {
  final String id;
  final String title;
  final List<String> lessons;

  CourseModule({
    required this.id,
    required this.title,
    required this.lessons,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      lessons: List<String>.from(json['lessons'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'lessons': lessons,
  };
}

class CourseModel {
  final String id;
  final String title;
  final String category;
  final String icon;
  final String level;
  final String duration;
  final double rating;
  final int studentsCount;
  final String description;
  final List<CourseModule> modules;
  final List<String> completedLessons;
  final int progressPercent;

  CourseModel({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.level,
    required this.duration,
    required this.rating,
    required this.studentsCount,
    required this.description,
    required this.modules,
    this.completedLessons = const [],
    this.progressPercent = 0,
  });

  int get totalLessons => modules.fold(0, (sum, m) => sum + m.lessons.length);

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    var rawModules = json['modules'] as List? ?? [];
    List<CourseModule> parsedModules = rawModules
        .map((m) => CourseModule.fromJson(Map<String, dynamic>.from(m)))
        .toList();

    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      icon: json['icon'] ?? 'school',
      level: json['level'] ?? 'Beginner',
      duration: json['duration'] ?? '10 hours',
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 4.8,
      studentsCount: json['studentsCount'] ?? 1000,
      description: json['description'] ?? '',
      modules: parsedModules,
      completedLessons: List<String>.from(json['completedLessons'] ?? []),
      progressPercent: json['progressPercent'] ?? 0,
    );
  }
}

