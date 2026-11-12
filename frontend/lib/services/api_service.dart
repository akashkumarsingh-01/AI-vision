import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  String _guestId = 'guest_flutter_user';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
    final savedGuest = prefs.getString(AppConstants.guestIdKey);
    if (savedGuest != null) {
      _guestId = savedGuest;
    } else {
      _guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(AppConstants.guestIdKey, _guestId);
    }
  }

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _headers({bool isJson = true}) {
    final headers = <String, String>{
      'x-guest-id': _guestId,
    };
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Uri _uri(String endpoint) {
    final base = AppConstants.baseUrl;
    if (base.startsWith('http')) {
      return Uri.parse('$base$endpoint');
    }
    // Web relative URL fallback
    return Uri.parse('$endpoint');
  }

  // --- Chat APIs ---
  Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    String? conversationId,
  }) async {
    final response = await http.post(
      _uri(AppConstants.chatEndpoint),
      headers: _headers(),
      body: jsonEncode({
        'message': message,
        'conversationId': conversationId,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getConversations() async {
    final response = await http.get(_uri(AppConstants.conversationsEndpoint), headers: _headers());
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getConversation(String id) async {
    final response = await http.get(_uri('${AppConstants.conversationsEndpoint}/$id'), headers: _headers());
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteConversation(String id) async {
    final response = await http.delete(_uri('${AppConstants.conversationsEndpoint}/$id'), headers: _headers());
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> clearConversation(String id) async {
    final response = await http.post(_uri('${AppConstants.conversationsEndpoint}/$id/clear'), headers: _headers());
    return jsonDecode(response.body);
  }

  // --- Multimodal APIs ---
  Future<Map<String, dynamic>> uploadAndAnalyzeImage({
    required Uint8List bytes,
    required String fileName,
    String? prompt,
  }) async {
    final request = http.MultipartRequest('POST', _uri(AppConstants.multimodalImageEndpoint));
    request.headers.addAll(_headers(isJson: false));
    if (prompt != null) request.fields['prompt'] = prompt;

    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: fileName,
      contentType: MediaType('image', fileName.endsWith('.png') ? 'png' : 'jpeg'),
    );
    request.files.add(multipartFile);

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> uploadAndAnalyzeDocument({
    required Uint8List bytes,
    required String fileName,
    String? prompt,
  }) async {
    final request = http.MultipartRequest('POST', _uri(AppConstants.multimodalDocEndpoint));
    request.headers.addAll(_headers(isJson: false));
    if (prompt != null) request.fields['prompt'] = prompt;

    final multipartFile = http.MultipartFile.fromBytes(
      'document',
      bytes,
      filename: fileName,
      contentType: MediaType('application', 'octet-stream'),
    );
    request.files.add(multipartFile);

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> uploadAndAnalyzeVideo({
    required Uint8List bytes,
    required String fileName,
    String? prompt,
  }) async {
    final request = http.MultipartRequest('POST', _uri(AppConstants.multimodalVideoEndpoint));
    request.headers.addAll(_headers(isJson: false));
    if (prompt != null) request.fields['prompt'] = prompt;

    final multipartFile = http.MultipartFile.fromBytes(
      'video',
      bytes,
      filename: fileName,
      contentType: MediaType('video', 'mp4'),
    );
    request.files.add(multipartFile);

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return jsonDecode(res.body);
  }

  // --- Learning APIs ---
  Future<Map<String, dynamic>> explainTopic({required String topic, String level = 'beginner'}) async {
    final response = await http.post(
      _uri(AppConstants.learnExplainEndpoint),
      headers: _headers(),
      body: jsonEncode({'topic': topic, 'level': level}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> generateNotes({required String topic, String format = 'cheat-sheet'}) async {
    final response = await http.post(
      _uri(AppConstants.learnNotesEndpoint),
      headers: _headers(),
      body: jsonEncode({'topic': topic, 'format': format}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> assistCode({
    required String code,
    String language = 'javascript',
    String instruction = 'Explain, debug, and optimize this code.',
  }) async {
    final response = await http.post(
      _uri(AppConstants.learnCodeEndpoint),
      headers: _headers(),
      body: jsonEncode({
        'code': code,
        'language': language,
        'instruction': instruction,
      }),
    );
    return jsonDecode(response.body);
  }

  // --- Courses APIs ---
  Future<Map<String, dynamic>> getCourses() async {
    final response = await http.get(_uri(AppConstants.coursesEndpoint), headers: _headers());
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getCourseById(String id) async {
    final response = await http.get(_uri('${AppConstants.coursesEndpoint}/$id'), headers: _headers());
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateCourseProgress({
    required String courseId,
    required String lessonTitle,
    bool completed = true,
  }) async {
    final response = await http.post(
      _uri('${AppConstants.coursesEndpoint}/$courseId/progress'),
      headers: _headers(),
      body: jsonEncode({
        'lessonTitle': lessonTitle,
        'completed': completed,
      }),
    );
    return jsonDecode(response.body);
  }

  // --- Quiz APIs ---
  Future<Map<String, dynamic>> generateQuiz({
    required String topic,
    int count = 5,
    String difficulty = 'medium',
  }) async {
    final response = await http.post(
      _uri('${AppConstants.quizEndpoint}/generate'),
      headers: _headers(),
      body: jsonEncode({
        'topic': topic,
        'count': count,
        'difficulty': difficulty,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> evaluateQuiz({
    required String quizId,
    required Map<String, dynamic> answers,
  }) async {
    final response = await http.post(
      _uri('${AppConstants.quizEndpoint}/evaluate'),
      headers: _headers(),
      body: jsonEncode({
        'quizId': quizId,
        'answers': answers,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getQuizHistory() async {
    final response = await http.get(_uri('${AppConstants.quizEndpoint}/history'), headers: _headers());
    return jsonDecode(response.body);
  }

  // --- Auth & User APIs ---
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final response = await http.post(
      _uri('${AppConstants.authEndpoint}/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      _uri('${AppConstants.authEndpoint}/register'),
      headers: _headers(),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(_uri('${AppConstants.authEndpoint}/profile'), headers: _headers());
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await http.put(
      _uri('${AppConstants.authEndpoint}/profile'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // --- Config APIs ---
  Future<Map<String, dynamic>> getConfigStatus() async {
    final response = await http.get(_uri('${AppConstants.configEndpoint}/status'), headers: _headers());
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateApiKey({required String apiKey, String? model}) async {
    final response = await http.post(
      _uri('${AppConstants.configEndpoint}/update-key'),
      headers: _headers(),
      body: jsonEncode({'apiKey': apiKey, if (model != null) 'model': model}),
    );
    return jsonDecode(response.body);
  }
}

