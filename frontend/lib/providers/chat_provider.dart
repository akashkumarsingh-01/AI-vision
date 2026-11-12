import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  String? _activeConversationId;
  List<MessageModel> _messages = [];
  List<ConversationModel> _conversations = [];
  bool _isLoading = false;
  String? _statusInfo;

  String? get activeConversationId => _activeConversationId;
  List<MessageModel> get messages => _messages;
  List<ConversationModel> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get statusInfo => _statusInfo;

  ChatProvider() {
    loadConversations();
  }

  Future<void> loadConversations() async {
    try {
      final res = await ApiService().getConversations();
      if (res['success'] == true) {
        final list = res['data'] as List? ?? [];
        _conversations = list.map((c) => ConversationModel.fromJson(Map<String, dynamic>.from(c))).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading conversations: $e');
    }
  }

  void startNewConversation() {
    _activeConversationId = null;
    _messages = [];
    notifyListeners();
  }

  Future<void> selectConversation(String id) async {
    _activeConversationId = id;
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService().getConversation(id);
      if (res['success'] == true) {
        final conv = ConversationModel.fromJson(Map<String, dynamic>.from(res['data']));
        _messages = conv.messages;
      }
    } catch (e) {
      debugPrint('Error selecting conversation: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Optimistically add user message
    final userMsg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: text.trim(),
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _isLoading = true;
    _statusInfo = 'Thinking with Gemini AI...';
    notifyListeners();

    try {
      final res = await ApiService().sendChatMessage(
        message: text.trim(),
        conversationId: _activeConversationId,
      );

      if (res['success'] == true) {
        final data = res['data'];
        _activeConversationId = data['conversationId'];
        final aiMsg = MessageModel.fromJson(Map<String, dynamic>.from(data['aiMessage']));
        _messages.add(aiMsg);
        loadConversations();
      } else {
        _messages.add(MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: 'assistant',
          content: 'Sorry, I encountered an issue: ${res['message']}',
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      _messages.add(MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: 'Network connection error: $e',
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      _statusInfo = null;
      notifyListeners();
    }
  }

  // Multimodal Image Analysis
  Future<void> sendImageAnalysis({
    required Uint8List bytes,
    required String fileName,
    String? prompt,
  }) async {
    final userMsg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: prompt ?? 'Analyze this image: $fileName',
      timestamp: DateTime.now(),
      attachmentType: 'image',
      attachmentName: fileName,
    );
    _messages.add(userMsg);
    _isLoading = true;
    _statusInfo = 'Analyzing image with Vision multimodal engine...';
    notifyListeners();

    try {
      final res = await ApiService().uploadAndAnalyzeImage(
        bytes: bytes,
        fileName: fileName,
        prompt: prompt,
      );

      if (res['success'] == true) {
        final data = res['data'];
        _messages.add(MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: 'assistant',
          content: data['analysis'] ?? 'Analysis complete.',
          timestamp: DateTime.now(),
          isLiveGemini: data['isLiveGemini'] ?? false,
          modelUsed: data['modelUsed'],
        ));
      }
    } catch (e) {
      _messages.add(MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: 'Error processing image: $e',
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      _statusInfo = null;
      notifyListeners();
    }
  }

  // Multimodal Document Analysis
  Future<void> sendDocumentAnalysis({
    required Uint8List bytes,
    required String fileName,
    String? prompt,
  }) async {
    final userMsg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: prompt ?? 'Analyze and summarize document: $fileName',
      timestamp: DateTime.now(),
      attachmentType: 'document',
      attachmentName: fileName,
    );
    _messages.add(userMsg);
    _isLoading = true;
    _statusInfo = 'Extracting document content and analyzing...';
    notifyListeners();

    try {
      final res = await ApiService().uploadAndAnalyzeDocument(
        bytes: bytes,
        fileName: fileName,
        prompt: prompt,
      );

      if (res['success'] == true) {
        final data = res['data'];
        _messages.add(MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: 'assistant',
          content: data['analysis'] ?? 'Document analysis complete.',
          timestamp: DateTime.now(),
          isLiveGemini: data['isLiveGemini'] ?? false,
          modelUsed: data['modelUsed'],
        ));
      }
    } catch (e) {
      _messages.add(MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: 'Error processing document: $e',
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      _statusInfo = null;
      notifyListeners();
    }
  }

  // Multimodal Video Analysis
  Future<void> sendVideoAnalysis({
    required Uint8List bytes,
    required String fileName,
    String? prompt,
  }) async {
    final userMsg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: prompt ?? 'Analyze video: $fileName',
      timestamp: DateTime.now(),
      attachmentType: 'video',
      attachmentName: fileName,
    );
    _messages.add(userMsg);
    _isLoading = true;
    _statusInfo = 'Processing video timestamps and visual narrative...';
    notifyListeners();

    try {
      final res = await ApiService().uploadAndAnalyzeVideo(
        bytes: bytes,
        fileName: fileName,
        prompt: prompt,
      );

      if (res['success'] == true) {
        final data = res['data'];
        _messages.add(MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: 'assistant',
          content: data['analysis'] ?? 'Video breakdown complete.',
          timestamp: DateTime.now(),
          isLiveGemini: data['isLiveGemini'] ?? false,
          modelUsed: data['modelUsed'],
        ));
      }
    } catch (e) {
      _messages.add(MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: 'Error processing video: $e',
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      _statusInfo = null;
      notifyListeners();
    }
  }

  Future<void> regenerateLastResponse() async {
    if (_messages.isEmpty) return;
    // Find last user message
    MessageModel? lastUserMsg;
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].isUser) {
        lastUserMsg = _messages[i];
        break;
      }
    }
    if (lastUserMsg != null) {
      // Remove trailing assistant message if present
      if (_messages.last.isAssistant) {
        _messages.removeLast();
      }
      notifyListeners();
      await sendMessage(lastUserMsg.content);
    }
  }

  Future<void> clearCurrentChat() async {
    if (_activeConversationId != null) {
      await ApiService().clearConversation(_activeConversationId!);
    }
    _messages = [];
    notifyListeners();
  }

  Future<void> deleteConversation(String id) async {
    await ApiService().deleteConversation(id);
    if (_activeConversationId == id) {
      startNewConversation();
    }
    loadConversations();
  }
}

