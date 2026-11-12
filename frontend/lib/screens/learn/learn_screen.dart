import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:provider/provider.dart';
import '../../providers/learn_provider.dart';
import '../../config/app_theme.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _explainTopicController = TextEditingController(text: 'Quantum Computing & Qubits');
  String _explainLevel = 'beginner';

  final TextEditingController _notesTopicController = TextEditingController(text: 'REST vs GraphQL API Architecture');
  String _notesFormat = 'cheat-sheet';

  final TextEditingController _codeSnippetController = TextEditingController(
    text: '''// Identify memory leaks or async bugs\nFuture<void> fetchData() async {\n  var response = await http.get(Uri.parse('https://api.example.com/data'));\n  print(response.body);\n}''',
  );
  String _codeLanguage = 'dart';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _explainTopicController.dispose();
    _notesTopicController.dispose();
    _codeSnippetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final learn = Provider.of<LearnProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Hub & AI Mentor', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          indicatorColor: AppTheme.primaryBlue,
          tabs: const [
            Tab(icon: Icon(Icons.school_outlined, size: 18), text: 'Explain Concept'),
            Tab(icon: Icon(Icons.menu_book_outlined, size: 18), text: 'Study Notes'),
            Tab(icon: Icon(Icons.code_rounded, size: 18), text: 'Code Assistant'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              height: 380,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExplainTab(context, learn),
                  _buildNotesTab(context, learn),
                  _buildCodeTab(context, learn),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Results Section
            if (learn.isLoading) ...[
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: AppTheme.primaryPurple),
                    const SizedBox(height: 16),
                    Text(
                      learn.statusMessage ?? 'Vision AI is generating educational content...',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ] else if (learn.resultContent != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('AI LEARNING OUTPUT', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () => learn.clearResult(),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    MarkdownBody(
                      data: learn.resultContent!,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                        p: TextStyle(fontFamily: 'Inter', fontSize: 14.5, height: 1.5),
                        code: TextStyle(fontFamily: 'monospace', 
                          fontSize: 13,
                          backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                          color: AppTheme.accentCyan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExplainTab(BuildContext context, LearnProvider learn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Explain Complex Topics In Simple Language', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 6),
        Text('Transform intricate computer science, physics, mathematics, or fitness concepts into intuitive analogies.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: const Color(0xFF94A3B8))),
        const SizedBox(height: 16),
        TextField(
          controller: _explainTopicController,
          decoration: const InputDecoration(labelText: 'Topic to Explain', prefixIcon: Icon(Icons.psychology_outlined)),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _explainLevel,
          decoration: const InputDecoration(labelText: 'Explanation Level', prefixIcon: Icon(Icons.tune_outlined)),
          items: const [
            DropdownMenuItem(value: 'beginner', child: Text('Like I am 10 (Intuitive analogies)')),
            DropdownMenuItem(value: 'intermediate', child: Text('Intermediate (Technical with architecture)')),
            DropdownMenuItem(value: 'advanced', child: Text('Advanced (Deep-dive internal mechanics)')),
          ],
          onChanged: (val) => setState(() => _explainLevel = val ?? 'beginner'),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.bolt, size: 18),
            label: const Text('Explain This Topic'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
            onPressed: () => learn.explainTopic(_explainTopicController.text.trim(), level: _explainLevel),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesTab(BuildContext context, LearnProvider learn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Generate High-Yield Study Notes & Summaries', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 6),
        Text('Synthesize key definitions, core principles, bulleted takeaways, and interview cheat sheets.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: const Color(0xFF94A3B8))),
        const SizedBox(height: 16),
        TextField(
          controller: _notesTopicController,
          decoration: const InputDecoration(labelText: 'Topic / Subject', prefixIcon: Icon(Icons.menu_book_outlined)),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _notesFormat,
          decoration: const InputDecoration(labelText: 'Format', prefixIcon: Icon(Icons.format_list_bulleted)),
          items: const [
            DropdownMenuItem(value: 'cheat-sheet', child: Text('Quick Reference Cheat Sheet')),
            DropdownMenuItem(value: 'detailed-summary', child: Text('Comprehensive Study Summary')),
            DropdownMenuItem(value: 'interview-prep', child: Text('Tech Interview High-Yield Q&A')),
          ],
          onChanged: (val) => setState(() => _notesFormat = val ?? 'cheat-sheet'),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.auto_stories, size: 18),
            label: const Text('Generate Study Notes'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple, foregroundColor: Colors.white),
            onPressed: () => learn.generateNotes(_notesTopicController.text.trim(), format: _notesFormat),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeTab(BuildContext context, LearnProvider learn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Programming Assistant & Bug Fixer', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 6),
        Text('Paste your code to analyze bottlenecks, fix runtime bugs, or refactor with clean architecture.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: const Color(0xFF94A3B8))),
        const SizedBox(height: 14),
        Expanded(
          child: TextField(
            controller: _codeSnippetController,
            maxLines: null,
            expands: true,
            style: TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Paste code snippet here...',
              alignLabelWithHint: true,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _codeLanguage,
                decoration: const InputDecoration(labelText: 'Language'),
                items: const [
                  DropdownMenuItem(value: 'dart', child: Text('Dart / Flutter')),
                  DropdownMenuItem(value: 'python', child: Text('Python')),
                  DropdownMenuItem(value: 'javascript', child: Text('JavaScript / React')),
                  DropdownMenuItem(value: 'java', child: Text('Java')),
                ],
                onChanged: (val) => setState(() => _codeLanguage = val ?? 'dart'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.build_rounded, size: 18),
                label: const Text('Optimize & Fix'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, minimumSize: const Size(0, 48)),
                onPressed: () => learn.assistCode(_codeSnippetController.text.trim(), language: _codeLanguage),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
