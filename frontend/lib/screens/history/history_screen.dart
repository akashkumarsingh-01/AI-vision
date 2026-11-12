import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/chat_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../config/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  final Function(int)? onNavigate;

  const HistoryScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chat = Provider.of<ChatProvider>(context);
    final quiz = Provider.of<QuizProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Activity & History', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18)),
          bottom: TabBar(
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            indicatorColor: AppTheme.primaryBlue,
            tabs: const [
              Tab(icon: Icon(Icons.chat_bubble_outline, size: 18), text: 'Conversations'),
              Tab(icon: Icon(Icons.quiz_outlined, size: 18), text: 'Quiz Assessments'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Conversations Tab
            chat.conversations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.forum_outlined, size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        Text('No conversations recorded yet.', style: TextStyle(fontFamily: 'Inter', fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Start a conversation in AI Chat to save history.', style: TextStyle(fontFamily: 'Inter', color: const Color(0xFF94A3B8))),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: chat.conversations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final c = chat.conversations[idx];
                      final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(c.updatedAt);

                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
                            child: const Icon(Icons.chat_bubble_rounded, color: AppTheme.primaryBlue, size: 18),
                          ),
                          title: Text(c.title, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text(
                            '${c.messageCount} messages • $dateStr',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: const Color(0xFF94A3B8)),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.errorRed),
                                tooltip: 'Delete Chat',
                                onPressed: () => chat.deleteConversation(c.id),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                            ],
                          ),
                          onTap: () {
                            chat.selectConversation(c.id);
                            if (onNavigate != null) onNavigate!(1);
                          },
                        ),
                      );
                    },
                  ),

            // Quiz Assessments Tab
            quiz.history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.quiz_outlined, size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        Text('No quiz records yet.', style: TextStyle(fontFamily: 'Inter', fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Generate and complete a quiz in the Quiz section.', style: TextStyle(fontFamily: 'Inter', color: const Color(0xFF94A3B8))),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: quiz.history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final h = quiz.history[idx];
                      final score = h['scorePercent'] ?? 0;
                      final isPassed = score >= 60;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: (isPassed ? AppTheme.successGreen : AppTheme.warningOrange).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$score%',
                                  style: TextStyle(fontFamily: 'Inter', 
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isPassed ? AppTheme.successGreen : AppTheme.warningOrange,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(h['topic'] ?? 'General Tech', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14)),
                                  Text(
                                    '${h['correctCount']} / ${h['totalQuestions']} correct • Level: ${h['difficulty']}',
                                    style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: const Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
