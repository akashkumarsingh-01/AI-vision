class MessageModel {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final bool isLiveGemini;
  final String? modelUsed;
  final String? attachmentType; // 'image', 'document', 'video'
  final String? attachmentName;

  MessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isLiveGemini = false,
    this.modelUsed,
    this.attachmentType,
    this.attachmentName,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      role: json['role'] ?? 'assistant',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      isLiveGemini: json['isLiveGemini'] ?? false,
      modelUsed: json['modelUsed'],
      attachmentType: json['attachmentType'],
      attachmentName: json['attachmentName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isLiveGemini': isLiveGemini,
      'modelUsed': modelUsed,
      'attachmentType': attachmentType,
      'attachmentName': attachmentName,
    };
  }
}

