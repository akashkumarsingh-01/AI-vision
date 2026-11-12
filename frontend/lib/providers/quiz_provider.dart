import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/api_service.dart';

class QuizProvider extends ChangeNotifier {
  QuizSession? _activeQuiz;
  Map<String, int> _userAnswers = {};
  QuizEvaluationResult? _lastResult;
  List<dynamic> _history = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _statusMessage;

  QuizSession? get activeQuiz => _activeQuiz;
  Map<String, int> get userAnswers => _userAnswers;
  QuizEvaluationResult? get lastResult => _lastResult;
  List<dynamic> get history => _history;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get statusMessage => _statusMessage;

  QuizProvider() {
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final res = await ApiService().getQuizHistory();
      if (res['success'] == true) {
        _stats = res['data']['stats'] ?? {};
        _history = res['data']['history'] ?? [];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading quiz history: $e');
    }
  }

  Future<bool> startQuiz({required String topic, int count = 5, String difficulty = 'medium'}) async {
    _isLoading = true;
    _statusMessage = 'AI is preparing custom questions on $topic...';
    _userAnswers = {};
    _lastResult = null;
    notifyListeners();

    try {
      final res = await ApiService().generateQuiz(topic: topic, count: count, difficulty: difficulty);
      if (res['success'] == true) {
        _activeQuiz = QuizSession.fromJson(Map<String, dynamic>.from(res['data']));
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error generating quiz: $e');
      return false;
    } finally {
      _isLoading = false;
      _statusMessage = null;
      notifyListeners();
    }
  }

  void selectAnswer(String questionId, int optionIndex) {
    _userAnswers[questionId] = optionIndex;
    notifyListeners();
  }

  Future<bool> submitQuiz() async {
    if (_activeQuiz == null) return false;

    _isLoading = true;
    _statusMessage = 'Evaluating answers and generating explanations...';
    notifyListeners();

    try {
      final res = await ApiService().evaluateQuiz(
        quizId: _activeQuiz!.id,
        answers: _userAnswers,
      );

      if (res['success'] == true) {
        _lastResult = QuizEvaluationResult.fromJson(Map<String, dynamic>.from(res['data']));
        loadHistory();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error evaluating quiz: $e');
      return false;
    } finally {
      _isLoading = false;
      _statusMessage = null;
      notifyListeners();
    }
  }

  void resetQuiz() {
    _activeQuiz = null;
    _userAnswers = {};
    _lastResult = null;
    notifyListeners();
  }
}

