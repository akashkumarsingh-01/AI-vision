import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/chat_provider.dart';
import '../../config/app_theme.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final courseProvider = Provider.of<CourseProvider>(context);
    final course = courseProvider.selectedCourse;

    if (course == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          course.level,
                          style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${course.duration} • ${course.studentsCount} Students',
                        style: TextStyle(fontFamily: 'Inter', color: Colors.white.withOpacity(0.85), fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    course.title,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white.withOpacity(0.9), height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overall Completion: ${course.progressPercent}%',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: course.progressPercent / 100.0,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'COURSE SYLLABUS & LESSONS',
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 14),

            // Modules list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: course.modules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, mIdx) {
                final module = course.modules[mIdx];
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      'Module ${mIdx + 1}: ${module.title}',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14.5, fontWeight: FontWeight.w700),
                    ),
                    children: module.lessons.map((lesson) {
                      final isCompleted = course.completedLessons.contains(lesson);
                      return ListTile(
                        leading: Checkbox(
                          value: isCompleted,
                          activeColor: AppTheme.primaryBlue,
                          onChanged: (val) {
                            courseProvider.toggleLesson(course.id, lesson, val ?? false);
                          },
                        ),
                        title: Text(
                          lesson,
                          style: TextStyle(fontFamily: 'Inter', 
                            fontSize: 13.5,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted
                                ? (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))
                                : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.help_outline_rounded, size: 18),
                          tooltip: 'Ask AI Mentor to explain this lesson',
                          onPressed: () {
                            Provider.of<ChatProvider>(context, listen: false).sendMessage(
                              'Please teach me about "$lesson" from the "${course.title}" course with clear examples and practice steps.',
                            );
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }).toList(),
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
