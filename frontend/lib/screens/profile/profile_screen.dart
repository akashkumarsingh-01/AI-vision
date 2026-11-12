import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _bioController.text = user.bio;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.updateProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
    );
    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Profile updated successfully' : 'Profile updated in session')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final stats = auth.stats;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile & Learning Analytics', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_rounded),
            tooltip: _isEditing ? 'Save Changes' : 'Edit Profile',
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primaryPurple.withOpacity(0.2),
                    child: const Icon(Icons.person, size: 38, color: AppTheme.primaryPurple),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _isEditing
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(labelText: 'Display Name'),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _bioController,
                                decoration: const InputDecoration(labelText: 'Short Bio'),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Explorer Guest',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'guest@visionai.dev',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: const Color(0xFF94A3B8)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user?.bio.isNotEmpty == true ? user!.bio : 'Lifelong learner on Vision AI.',
                                style: TextStyle(fontFamily: 'Inter', 
                                  fontSize: 13,
                                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Metrics / Stats Grid
            Text(
              'LEARNING PERFORMANCE METRICS',
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
                final count = constraints.maxWidth > 700 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: count,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.6,
                  children: [
                    _StatTile(
                      label: 'Conversations',
                      value: '${stats.conversationsCount}',
                      icon: Icons.chat_rounded,
                      color: AppTheme.primaryBlue,
                    ),
                    _StatTile(
                      label: 'Quizzes Taken',
                      value: '${stats.quizzesTaken}',
                      icon: Icons.quiz_rounded,
                      color: AppTheme.primaryPurple,
                    ),
                    _StatTile(
                      label: 'Avg Quiz Score',
                      value: '${stats.avgQuizScore}%',
                      icon: Icons.grade_rounded,
                      color: AppTheme.successGreen,
                    ),
                    _StatTile(
                      label: 'Lessons Done',
                      value: '${stats.totalLessonsFinished}',
                      icon: Icons.checklist_rounded,
                      color: AppTheme.accentCyan,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // Active Learning Goals
            Text(
              'ACTIVE LEARNING GOALS',
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
              child: Column(
                children: [
                  _GoalItem(title: 'Master Flutter Cross-Platform Architecture', isDone: true),
                  _GoalItem(title: 'Explore Gemini Multimodal Reasoning with Video & Audio', isDone: true),
                  _GoalItem(title: 'Build Resilient Full-Stack REST API Microservices', isDone: false),
                  _GoalItem(title: 'Complete 10 Interactive Technology Quizzes', isDone: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

class _GoalItem extends StatelessWidget {
  final String title;
  final bool isDone;

  const _GoalItem({required this.title, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isDone ? AppTheme.successGreen : const Color(0xFF94A3B8),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 13.5,
                decoration: isDone ? TextDecoration.lineThrough : null,
                color: isDone ? const Color(0xFF94A3B8) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
