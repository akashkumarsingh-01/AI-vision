import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../config/constants.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  UserStats _stats = UserStats();
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  UserStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService().getProfile();
      if (res['success'] == true) {
        _user = UserModel.fromJson(res['data']['profile']);
        _stats = UserStats.fromJson(res['data']['stats'] ?? {});
      }
    } catch (e) {
      // Default to guest user
      _user = UserModel(
        id: 'guest_user',
        name: 'Vision Explorer',
        email: 'explorer@visionai.io',
        avatar: 'https://api.dicebear.com/7.x/bottts/svg?seed=Explorer',
        bio: 'Exploring Vision AI Multimodal capabilities',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService().login(email: email, password: password);
      if (res['success'] == true) {
        final token = res['data']['token'];
        ApiService().setToken(token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);
        _user = UserModel.fromJson(res['data']['user']);
        await loadUser();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Login failed';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService().register(name: name, email: email, password: password);
      if (res['success'] == true) {
        final token = res['data']['token'];
        ApiService().setToken(token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);
        _user = UserModel.fromJson(res['data']['user']);
        await loadUser();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Registration failed';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    ApiService().setToken(null);
    _user = null;
    loadUser();
  }

  Future<bool> updateProfile({String? name, String? bio, List<String>? learningGoals}) async {
    try {
      final res = await ApiService().updateProfile({
        if (name != null) 'name': name,
        if (bio != null) 'bio': bio,
        if (learningGoals != null) 'learningGoals': learningGoals,
      });
      if (res['success'] == true) {
        await loadUser();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
    return false;
  }
}

