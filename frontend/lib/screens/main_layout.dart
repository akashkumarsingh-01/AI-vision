import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../widgets/sidebar_navigation.dart';
import '../providers/theme_provider.dart';
import '../config/app_theme.dart';
import 'home/home_screen.dart';
import 'chat/chat_screen.dart';
import 'courses/courses_screen.dart';
import 'quiz/quiz_screen.dart';
import 'learn/learn_screen.dart';
import 'history/history_screen.dart';
import 'profile/profile_screen.dart';
import 'settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    final screens = [
      HomeScreen(onNavigate: _onNavigate),
      const ChatScreen(),
      const CoursesScreen(),
      const QuizScreen(),
      const LearnScreen(),
      HistoryScreen(onNavigate: _onNavigate),
      const ProfileScreen(),
      const SettingsScreen(),
    ];

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            SidebarNavigation(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onNavigate,
            ),
            Expanded(
              child: screens[_currentIndex],
            ),
          ],
        ),
      );
    }

    // Mobile / Tablet Drawer Layout
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              'Vision AI',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 20),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, size: 20),
            onPressed: () => _onNavigate(6),
          ),
        ],
      ),
      drawer: Drawer(
        child: SidebarNavigation(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) {
            Navigator.pop(context); // close drawer
            _onNavigate(idx);
          },
        ),
      ),
      body: screens[_currentIndex],
    );
  }
}
