import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:intl/intl.dart';
import '../models/message_model.dart';
import '../config/app_theme.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final VoidCallback? onRegenerate;
  final VoidCallback? onSpeak;

  const ChatBubble({
    super.key,
    required this.message,
    this.onRegenerate,
    this.onSpeak,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied response to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.isUser;
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 750),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.primaryBlue
                    : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: Border.all(
                  color: isUser
                      ? Colors.transparent
                      : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Attachment badge if present
                  if (message.attachmentType != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            message.attachmentType == 'image'
                                ? Icons.image
                                : message.attachmentType == 'video'
                                    ? Icons.video_library
                                    : Icons.description,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            message.attachmentName ?? 'Attachment',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Content (Markdown for AI, Text for user)
                  if (isUser)
                    Text(
                      message.content,
                      style: TextStyle(fontFamily: 'Inter', 
                        fontSize: 15,
                        color: Colors.white,
                        height: 1.45,
                      ),
                    )
                  else
                    MarkdownBody(
                      data: message.content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                        p: TextStyle(fontFamily: 'Inter', 
                          fontSize: 14.5,
                          height: 1.5,
                          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                        ),
                        code: TextStyle(fontFamily: 'monospace', 
                          fontSize: 13,
                          backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                          color: AppTheme.accentCyan,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Footer with time, badges and action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(fontFamily: 'Inter', 
                          fontSize: 11,
                          color: isUser
                              ? Colors.white.withOpacity(0.7)
                              : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                        ),
                      ),
                      if (!isUser) ...[
                        const SizedBox(width: 10),
                        if (message.isLiveGemini)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.bolt, size: 11, color: AppTheme.primaryPurple),
                                const SizedBox(width: 2),
                                Text(
                                  'Gemini',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppTheme.primaryPurple, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        // Copy button
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          tooltip: 'Copy',
                          onPressed: () => _copyToClipboard(context),
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 10),
                        // TTS read button
                        if (onSpeak != null)
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded, size: 16),
                            tooltip: 'Read Aloud',
                            onPressed: onSpeak,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 19,
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.2),
              child: const Icon(Icons.person, color: AppTheme.primaryBlue, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}
