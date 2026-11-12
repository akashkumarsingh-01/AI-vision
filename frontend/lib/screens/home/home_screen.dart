import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _quickPrompts = [
    'Explain how Flutter compiles to Web & Native',
    'Write a Python script to parse JSON and call Gemini API',
    'What is the difference between useMemo and useCallback in React?',
    'Design an algorithm for binary search tree balancing',
    'Explain quantum computing like I am 10 years old',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider>(context);
    final chat = Provider.of<ChatProvider>(context);

    final userName = auth.user?.name ?? 'Explorer';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header & Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF312E81), Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars, color: Colors.amberAccent, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Vision AI 2.0 • Gemini Intelligence',
                              style: TextStyle(fontFamily: 'Inter', 
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome back, $userName 👋',
                    style: TextStyle(fontFamily: 'Inter', 
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your intelligent all-in-one assistant for programming, education, multimodal vision, quizzes, and real-time knowledge.',
                    style: TextStyle(fontFamily: 'Inter', 
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                        label: const Text('Start AI Chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () => widget.onNavigate(1),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.school, size: 18, color: Colors.white),
                        label: const Text('Explore Courses', style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 1.5),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => widget.onNavigate(2),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search anything (e.g. Flutter widgets, Python decorators, React hooks, Quizzes)...',
                  hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, color: const Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onSubmitted: (query) {
                  if (query.trim().isNotEmpty) {
                    chat.sendMessage(query.trim());
                    widget.onNavigate(1);
                  }
                },
              ),
            ),

            const SizedBox(height: 28),

            // Quick Access Feature Cards Grid
            Text(
              'QUICK ACCESS FEATURES',
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 14),

            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.7,
                  children: [
                    _FeatureCard(
                      title: 'AI Chat Assistant',
                      description: 'Real-time multi-turn conversational AI powered by Google Gemini.',
                      icon: Icons.chat_rounded,
                      color: AppTheme.primaryBlue,
                      onTap: () => widget.onNavigate(1),
                    ),
                    _FeatureCard(
                      title: 'Multimodal Vision',
                      description: 'Upload images, PDFs, docs, and videos for deep semantic reasoning.',
                      icon: Icons.remove_red_eye_rounded,
                      color: AppTheme.primaryPurple,
                      onTap: () => widget.onNavigate(1),
                    ),
                    _FeatureCard(
                      title: 'Tech Courses',
                      description: 'Flutter, Python, React, JavaScript, Java, HTML/CSS roadmaps.',
                      icon: Icons.school_rounded,
                      color: const Color(0xFF0EA5E9),
                      onTap: () => widget.onNavigate(2),
                    ),
                    _FeatureCard(
                      title: 'AI Quiz Master',
                      description: 'Instant AI question generation, score tracking, and detailed explanations.',
                      icon: Icons.quiz_rounded,
                      color: const Color(0xFF10B981),
                      onTap: () => widget.onNavigate(3),
                    ),
                    _FeatureCard(
                      title: 'Learning Hub',
                      description: 'Explain difficult topics simply, generate study notes, and debug code.',
                      icon: Icons.lightbulb_rounded,
                      color: const Color(0xFFF59E0B),
                      onTap: () => widget.onNavigate(4),
                    ),
                    _FeatureCard(
                      title: 'Conversation History',
                      description: 'Revisit saved chats, previous quiz assessments, and progress.',
                      icon: Icons.history_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () => widget.onNavigate(5),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // Quick Prompt Ideas
            Text(
              'POPULAR INQUIRIES & PROMPTS',
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _quickPrompts.map((p) => ActionChip(
                avatar: const Icon(Icons.bolt, size: 16, color: AppTheme.primaryPurple),
                label: Text(p, style: TextStyle(fontFamily: 'Inter', fontSize: 13)),
                backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                side: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: () {
                  chat.sendMessage(p);
                  widget.onNavigate(1);
                },
              )).toList(),
            ),

            const SizedBox(height: 28),

            // Recent Conversations Preview
            if (chat.conversations.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECENT DISCUSSIONS',
                    style: TextStyle(fontFamily: 'Inter', 
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigate(5),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: chat.conversations.take(3).length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final c = chat.conversations[idx];
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryBlue, size: 20),
                      ),
                      title: Text(c.title, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(
                        c.lastMessage.isNotEmpty ? c.lastMessage : 'Tap to continue conversation...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 12),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () {
                        chat.selectConversation(c.id);
                        widget.onNavigate(1);
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
