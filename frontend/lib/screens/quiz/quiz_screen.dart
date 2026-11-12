import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../config/app_theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TextEditingController _topicController = TextEditingController(text: 'Flutter & Dart Architecture');
  String _difficulty = 'medium';
  int _questionCount = 5;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quiz = Provider.of<QuizProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('AI Quiz Master', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          if (quiz.activeQuiz != null || quiz.lastResult != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'New Quiz',
              onPressed: () => quiz.resetQuiz(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // If active quiz is running
            if (quiz.activeQuiz != null && quiz.lastResult == null)
              _buildQuizTaker(context, quiz)
            // If evaluation result is available
            else if (quiz.lastResult != null)
              _buildResultView(context, quiz)
            // Default quiz generator creation form
            else
              _buildGeneratorForm(context, quiz),

            const SizedBox(height: 36),

            // Performance Tracking & History
            if (quiz.history.isNotEmpty && quiz.activeQuiz == null) ...[
              Text(
                'PAST QUIZ PERFORMANCES',
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: quiz.history.take(5).length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final h = quiz.history[idx];
                  final score = h['scorePercent'] ?? 0;
                  final isGood = score >= 70;
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h['topic'] ?? 'General Tech', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(
                              '${h['correctCount']} / ${h['totalQuestions']} correct • ${h['difficulty']}',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: const Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isGood ? AppTheme.successGreen : AppTheme.warningOrange).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$score%',
                            style: TextStyle(fontFamily: 'Inter', 
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isGood ? AppTheme.successGreen : AppTheme.warningOrange,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildGeneratorForm(BuildContext context, QuizProvider quiz) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Generate AI Challenge', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Instant evaluation with deep pedagogical explanations', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: const Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Topic input
          Text('Quiz Topic / Technology', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _topicController,
            decoration: const InputDecoration(
              hintText: 'e.g. Python AsyncIO, React Hooks, Docker & Kubernetes...',
              prefixIcon: Icon(Icons.topic_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 18),

          // Difficulty & Count row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Difficulty', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _difficulty,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                      items: const [
                        DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                        DropdownMenuItem(value: 'medium', child: Text('Intermediate')),
                        DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                      ],
                      onChanged: (val) => setState(() => _difficulty = val ?? 'medium'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Questions Count', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _questionCount,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                      items: const [
                        DropdownMenuItem(value: 3, child: Text('3 Questions')),
                        DropdownMenuItem(value: 5, child: Text('5 Questions')),
                        DropdownMenuItem(value: 10, child: Text('10 Questions')),
                      ],
                      onChanged: (val) => setState(() => _questionCount = val ?? 5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Generate CTA
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: quiz.isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(quiz.isLoading ? (quiz.statusMessage ?? 'Preparing Quiz...') : 'Generate & Start Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: quiz.isLoading
                  ? null
                  : () {
                      if (_topicController.text.trim().isNotEmpty) {
                        quiz.startQuiz(
                          topic: _topicController.text.trim(),
                          count: _questionCount,
                          difficulty: _difficulty,
                        );
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTaker(BuildContext context, QuizProvider quiz) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qSession = quiz.activeQuiz!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Topic: ${qSession.topic}',
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue),
              ),
              Text(
                '${quiz.userAnswers.length} of ${qSession.questions.length} answered',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: qSession.questions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, qIdx) {
            final q = qSession.questions[qIdx];
            final selectedIdx = quiz.userAnswers[q.id];

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${qIdx + 1}. ${q.question}',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(q.options.length, (optIdx) {
                    final isChosen = selectedIdx == optIdx;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => quiz.selectAnswer(q.id, optIdx),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isChosen
                                ? AppTheme.primaryBlue.withOpacity(0.15)
                                : (isDark ? AppTheme.darkSurface : AppTheme.lightSurface),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isChosen ? AppTheme.primaryBlue : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isChosen ? AppTheme.primaryBlue : Colors.transparent,
                                  border: Border.all(
                                    color: isChosen ? AppTheme.primaryBlue : const Color(0xFF94A3B8),
                                  ),
                                ),
                                child: isChosen
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(q.options[optIdx], style: TextStyle(fontFamily: 'Inter', fontSize: 13.5)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            icon: quiz.isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.check_circle_outline_rounded),
            label: Text(quiz.isLoading ? 'Evaluating with AI...' : 'Submit Answers for Instant Evaluation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: quiz.isLoading ? null : () => quiz.submitQuiz(),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView(BuildContext context, QuizProvider quiz) {
    final res = quiz.lastResult!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPassed = res.scorePercent >= 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score Header Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPassed
                  ? [const Color(0xFF065F46), const Color(0xFF10B981)]
                  : [const Color(0xFF991B1B), const Color(0xFFEF4444)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${res.scorePercent}%',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPassed ? 'Outstanding Work!' : 'Good Effort! Keep Practicing',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You scored ${res.correctCount} out of ${res.totalQuestions} questions correct.',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'DETAILED EXPLANATIONS & BREAKDOWN',
          style: TextStyle(fontFamily: 'Inter', 
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: res.breakdown.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, idx) {
            final item = res.breakdown[idx];
            final correct = item['isCorrect'] == true;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: correct ? AppTheme.successGreen.withOpacity(0.4) : AppTheme.errorRed.withOpacity(0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: correct ? AppTheme.successGreen : AppTheme.errorRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['question'] ?? '',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your answer: ${item['userAnswerText']}',
                    style: TextStyle(fontFamily: 'Inter', 
                      fontSize: 13,
                      color: correct ? AppTheme.successGreen : AppTheme.errorRed,
                    ),
                  ),
                  if (!correct) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Correct answer: ${item['correctAnswerText']}',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppTheme.successGreen, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '💡 Explanation: ${item['explanation']}',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12.5, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Another Quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => quiz.resetQuiz(),
          ),
        ),
      ],
    );
  }
}
