import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/api_service.dart';

class CourseProvider extends ChangeNotifier {
  List<CourseModel> _courses = [];
  CourseModel? _selectedCourse;
  bool _isLoading = false;
  String _selectedCategory = 'All';

  List<CourseModel> get courses => _courses;
  CourseModel? get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  List<String> get categories => ['All', 'Mobile & Web', 'Programming & AI', 'Web Development', 'Enterprise Software', 'Web Design'];

  List<CourseModel> get filteredCourses {
    if (_selectedCategory == 'All') return _courses;
    return _courses.where((c) => c.category == _selectedCategory).toList();
  }

  CourseProvider() {
    loadCourses();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService().getCourses();
      if (res['success'] == true) {
        final list = res['data'] as List? ?? [];
        _courses = list.map((c) => CourseModel.fromJson(Map<String, dynamic>.from(c))).toList();
      }
    } catch (e) {
      debugPrint('Error loading courses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCourse(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService().getCourseById(id);
      if (res['success'] == true) {
        _selectedCourse = CourseModel.fromJson(Map<String, dynamic>.from(res['data']));
      }
    } catch (e) {
      debugPrint('Error selecting course: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLesson(String courseId, String lessonTitle, bool completed) async {
    try {
      final res = await ApiService().updateCourseProgress(
        courseId: courseId,
        lessonTitle: lessonTitle,
        completed: completed,
      );
      if (res['success'] == true) {
        await selectCourse(courseId);
        loadCourses();
      }
    } catch (e) {
      debugPrint('Error toggling lesson progress: $e');
    }
  }
}

