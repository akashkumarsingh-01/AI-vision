import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/theme_provider.dart';
import '../../config/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  String _selectedModel = 'gemini-1.5-flash';
  bool _hasActiveKey = false;
  bool _isLoading = false;
  bool _voiceAutoSpeech = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _fetchConfig();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _fetchConfig() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService().getConfigStatus();
      if (res['success'] == true) {
        final data = res['data'];
        setState(() {
          _hasActiveKey = data['hasGeminiApiKey'] ?? false;
          _selectedModel = data['geminiModel'] ?? 'gemini-1.5-flash';
        });
      }
    } catch (e) {
      debugPrint('Error fetching config status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final res = await ApiService().updateApiKey(
        apiKey: key,
        model: _selectedModel,
      );

      if (res['success'] == true) {
        setState(() {
          _hasActiveKey = res['data']['hasGeminiApiKey'] ?? false;
          _statusMessage = res['message'];
        });
        _apiKeyController.clear();
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error updating configuration: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings & Configuration', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gemini API Key & Model Configuration Card
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.key_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Google Gemini API Key', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('Secure backend key integration', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: const Color(0xFF94A3B8))),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (_hasActiveKey ? AppTheme.successGreen : AppTheme.warningOrange).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _hasActiveKey ? Icons.check_circle : Icons.info_outline,
                              size: 14,
                              color: _hasActiveKey ? AppTheme.successGreen : AppTheme.warningOrange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _hasActiveKey ? 'Key Active' : 'Local Intelligent Mode',
                              style: TextStyle(fontFamily: 'Inter', 
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _hasActiveKey ? AppTheme.successGreen : AppTheme.warningOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Vision AI includes an intelligent fallback engine, so everything works out-of-the-box. To connect directly to your Google Gemini cloud quota, enter your API key below.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: const Color(0xFF94A3B8), height: 1.4),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: _hasActiveKey ? '•••••••••••••••••••••••••••• (Active)' : 'Paste your Gemini API key (AIzaSy...)',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Model Selection
                  DropdownButtonFormField<String>(
                    value: _selectedModel,
                    decoration: const InputDecoration(labelText: 'Gemini Model Selection', prefixIcon: Icon(Icons.memory_rounded)),
                    items: const [
                      DropdownMenuItem(value: 'gemini-1.5-flash', child: Text('gemini-1.5-flash (Fast & Multimodal)')),
                      DropdownMenuItem(value: 'gemini-1.5-pro', child: Text('gemini-1.5-pro (High Reasoning Depth)')),
                      DropdownMenuItem(value: 'gemini-2.0-flash-exp', child: Text('gemini-2.0-flash-exp (Experimental)')),
                    ],
                    onChanged: (val) => setState(() => _selectedModel = val ?? 'gemini-1.5-flash'),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: Text(_isLoading ? 'Updating...' : 'Save & Verify Gemini Key'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _saveApiKey,
                    ),
                  ),

                  if (_statusMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage!,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12.5, color: AppTheme.successGreen, fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Appearance & Voice Settings Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preferences & Audio', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: Text('Dark Theme Mode', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text('Toggle between sleek dark and clean light modes', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: const Color(0xFF94A3B8))),
                    value: themeProvider.isDark,
                    activeColor: AppTheme.primaryPurple,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),

                  const Divider(height: 20),

                  SwitchListTile(
                    title: Text('Auto Text-to-Speech (TTS)', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text('Automatically read assistant messages aloud', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: const Color(0xFF94A3B8))),
                    value: _voiceAutoSpeech,
                    activeColor: AppTheme.primaryPurple,
                    onChanged: (val) => setState(() => _voiceAutoSpeech = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Platform Info
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vision AI Version 2.0.0 • Connected to Node.js backend on http://localhost:5000',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: const Color(0xFF94A3B8)),
                    ),
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
