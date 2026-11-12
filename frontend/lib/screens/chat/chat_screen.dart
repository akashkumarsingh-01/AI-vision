import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/multimodal_attachment_bar.dart';
import '../../config/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    Provider.of<ChatProvider>(context, listen: false).sendMessage(text);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _toggleMic() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listening via microphone... (Speak now)'),
          duration: Duration(seconds: 3),
        ),
      );
      // Simulate speech recognition input if native mic plugin is not connected
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isListening) {
          setState(() {
            _isListening = false;
            _textController.text = 'Explain multimodal AI vision algorithms and use cases in modern robotics.';
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chat = Provider.of<ChatProvider>(context);

    // Auto scroll when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chat.isLoading) _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, size: 16, color: AppTheme.primaryPurple),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                chat.activeConversationId != null ? 'Active Conversation' : 'Vision AI Chat',
                style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined, size: 20),
            tooltip: 'New Conversation',
            onPressed: () => chat.startNewConversation(),
          ),
          if (chat.messages.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              tooltip: 'Regenerate Last Response',
              onPressed: () => chat.regenerateLastResponse(),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              tooltip: 'Clear Chat Messages',
              onPressed: () => chat.clearCurrentChat(),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Multimodal Attachment Bar (Images, PDF, Video)
          const MultimodalAttachmentBar(),
          const Divider(height: 1),

          // Message stream or Welcome empty state
          Expanded(
            child: chat.messages.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 12, bottom: 20),
                    itemCount: chat.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chat.messages[index];
                      return ChatBubble(
                        message: msg,
                        onSpeak: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reading response aloud via Text-to-Speech...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),

          // Loading typing indicator
          if (chat.isLoading) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryPurple),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    chat.statusInfo ?? 'Vision AI is formulating response...',
                    style: TextStyle(fontFamily: 'Inter', 
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Floating Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              border: Border(
                top: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
            ),
            child: Row(
              children: [
                // Mic button
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none_rounded,
                    color: _isListening ? AppTheme.errorRed : AppTheme.primaryPurple,
                  ),
                  tooltip: _isListening ? 'Stop Listening' : 'Voice Input (Speech-to-Text)',
                  onPressed: _toggleMic,
                ),
                const SizedBox(width: 4),

                // Text field
                Expanded(
                  child: TextField(
                    controller: _textController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: 'Ask Vision AI anything (code, theory, science, fitness, summary)...',
                      hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, color: const Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                    tooltip: 'Send Message',
                    onPressed: _handleSend,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'How can Vision AI assist you today?',
              style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Communicate through text, speech, images, PDFs, or videos.',
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 14,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Starter Suggestions
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionCard(
                  title: 'Multimodal Vision',
                  subtitle: 'Upload an image or diagram to solve',
                  icon: Icons.image_search_rounded,
                  onTap: () {
                    _textController.text = 'Analyze this diagram and explain the system architecture.';
                  },
                ),
                _SuggestionCard(
                  title: 'Debug Flutter Code',
                  subtitle: 'Fix widget rebuild and state bugs',
                  icon: Icons.code_rounded,
                  onTap: () {
                    _textController.text = 'Debug my Flutter Provider state management implementation.';
                  },
                ),
                _SuggestionCard(
                  title: 'Document Summary',
                  subtitle: 'Ingest PDF and generate executive notes',
                  icon: Icons.description_rounded,
                  onTap: () {
                    _textController.text = 'Summarize key takeaways from this technical specification document.';
                  },
                ),
                _SuggestionCard(
                  title: 'Learn AI Algorithms',
                  subtitle: 'Explain backpropagation in deep learning',
                  icon: Icons.psychology_rounded,
                  onTap: () {
                    _textController.text = 'Explain gradient descent and backpropagation with mathematical intuition.';
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SuggestionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryPurple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(
                    subtitle,
                    style: TextStyle(fontFamily: 'Inter', 
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
