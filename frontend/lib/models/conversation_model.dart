import 'message_model.dart';

class ConversationModel {
  final String id;
  final String title;
  final List<MessageModel> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get messageCount => messages.length;
  String get lastMessage => messages.isNotEmpty ? messages.last.content : '';

  ConversationModel({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    var rawList = json['messages'] as List? ?? [];
    List<MessageModel> parsedMessages = rawList
        .map((m) => MessageModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();

    return ConversationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'New Chat',
      messages: parsedMessages,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
