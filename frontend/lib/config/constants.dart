import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appName = 'Vision AI';
  static const String appVersion = '2.0.0';

  // Base API URL: In Web release mode, relative `/api` is used.
  // In debug mode or desktop, localhost:5000 is used.
  static String get baseUrl {
    if (kIsWeb) {
      return '/api';
    }
    return 'http://localhost:5000/api';
  }

  // Endpoints
  static const String chatEndpoint = '/chat';
  static const String conversationsEndpoint = '/chat/conversations';
  static const String multimodalImageEndpoint = '/multimodal/image';
  static const String multimodalDocEndpoint = '/multimodal/document';
  static const String multimodalVideoEndpoint = '/multimodal/video';
  static const String learnExplainEndpoint = '/learn/explain';
  static const String learnNotesEndpoint = '/learn/notes';
  static const String learnCodeEndpoint = '/learn/code-assist';
  static const String coursesEndpoint = '/courses';
  static const String quizEndpoint = '/quiz';
  static const String authEndpoint = '/auth';
  static const String configEndpoint = '/config';

  // Local storage keys
  static const String tokenKey = 'vision_ai_token';
  static const String userKey = 'vision_ai_user';
  static const String themeKey = 'vision_ai_theme';
  static const String guestIdKey = 'vision_ai_guest_id';
}

