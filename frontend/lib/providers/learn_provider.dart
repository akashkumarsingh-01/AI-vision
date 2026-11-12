import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LearnProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _resultContent;
  String? _activeMode; // 'explain', 'notes', 'code'
  String? _statusMessage;

  bool get isLoading => _isLoading;
  String? get resultContent => _resultContent;
  String? get activeMode => _activeMode;
  String? get statusMessage => _statusMessage;

  Future<void> explainTopic(String topic, {String level = 'beginner'}) async {
    _isLoading = true;
    _activeMode = 'explain';
    _statusMessage = 'Vision AI is breaking down "$topic" for $level level...';
    _resultContent = null;
    notifyListeners();

    try {
      final res = await ApiService().explainTopic(topic: topic, level: level);
      if (res['success'] == true) {
        _resultContent = res['data']['explanation'];
      } else {
        _resultContent = 'Could not generate explanation: ${res['message']}';
      }
    } catch (e) {
      _resultContent = 'Error: $e';
    } finally {
      _isLoading = false;
      _statusMessage = null;
      notifyListeners();
    }
  }

  Future<void> generateNotes(String topic, {String format = 'cheat-sheet'}) async {
    _isLoading = true;
    _activeMode = 'notes';
    _statusMessage = 'Synthesizing comprehensive notes for "$topic"...';
    _resultContent = null;
    notifyListeners();

    try {
      final res = await ApiService().generateNotes(topic: topic, format: format);
      if (res['success'] == true) {
        _resultContent = res['data']['notes'];
      } else {
        _resultContent = 'Could not generate notes: ${res['message']}';
      }
    } catch (e) {
      _resultContent = 'Error: $e';
    } finally {
      _isLoading = false;
      _statusMessage = null;
      notifyListeners();
    }
  }

  Future<void> assistCode(String code, {String language = 'javascript', String instruction = 'Explain and optimize this code.'}) async {
    _isLoading = true;
    _activeMode = 'code';
    _statusMessage = 'Analyzing code structure, performance, and best practices...';
    _resultContent = null;
    notifyListeners();

    try {
      final res = await ApiService().assistCode(code: code, language: language, instruction: instruction);
      if (res['success'] == true) {
        _resultContent = res['data']['result'];
      } else {
        _resultContent = 'Could not assist code: ${res['message']}';
      }
    } catch (e) {
      _resultContent = 'Error: $e';
    } finally {
      _isLoading = false;
      _statusMessage = null;
      notifyListeners();
    }
  }

  void clearResult() {
    _resultContent = null;
    _activeMode = null;
    notifyListeners();
  }
}

