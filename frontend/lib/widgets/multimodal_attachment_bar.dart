import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../config/app_theme.dart';

class MultimodalAttachmentBar extends StatelessWidget {
  const MultimodalAttachmentBar({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    );

    if (result.isNotEmpty) {
      final file = result.first;
      final bytes = await file.xFile.readAsBytes();
      if (!context.mounted) return;
      _showPromptDialog(
        context,
        title: 'Analyze Image with Vision AI',
        fileName: file.name,
        defaultPrompt: 'Analyze this image in detail. Identify objects, text, design, or solve any questions visible.',
        onConfirm: (prompt) {
          Provider.of<ChatProvider>(context, listen: false).sendImageAnalysis(
            bytes: bytes,
            fileName: file.name,
            prompt: prompt,
          );
        },
      );
    }
  }

  Future<void> _pickDocument(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'md', 'json', 'csv'],
    );

    if (result.isNotEmpty) {
      final file = result.first;
      final bytes = await file.xFile.readAsBytes();
      if (!context.mounted) return;
      _showPromptDialog(
        context,
        title: 'Analyze Document / PDF',
        fileName: file.name,
        defaultPrompt: 'Provide an executive summary, list key findings, and extract actionable takeaways from this document.',
        onConfirm: (prompt) {
          Provider.of<ChatProvider>(context, listen: false).sendDocumentAnalysis(
            bytes: bytes,
            fileName: file.name,
            prompt: prompt,
          );
        },
      );
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'webm', 'mov', 'mkv'],
    );

    if (result.isNotEmpty) {
      final file = result.first;
      final bytes = await file.xFile.readAsBytes();
      if (!context.mounted) return;
      _showPromptDialog(
        context,
        title: 'Analyze Video with Vision AI',
        fileName: file.name,
        defaultPrompt: 'Analyze this video. Break down key scenes, time-stamped events, and provide educational takeaways.',
        onConfirm: (prompt) {
          Provider.of<ChatProvider>(context, listen: false).sendVideoAnalysis(
            bytes: bytes,
            fileName: file.name,
            prompt: prompt,
          );
        },
      );
    }
  }

  void _showPromptDialog(
    BuildContext context, {
    required String title,
    required String fileName,
    required String defaultPrompt,
    required Function(String) onConfirm,
  }) {
    final controller = TextEditingController(text: defaultPrompt);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, size: 16, color: AppTheme.primaryPurple),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      fileName,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('What would you like Vision AI to analyze?', style: TextStyle(fontFamily: 'Inter', fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your custom prompt...',
                hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm(controller.text);
            },
            child: const Text('Send to AI'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          _AttachmentChip(
            icon: Icons.image_rounded,
            label: 'Image',
            color: const Color(0xFF3B82F6),
            onTap: () => _pickImage(context),
          ),
          const SizedBox(width: 8),
          _AttachmentChip(
            icon: Icons.picture_as_pdf_rounded,
            label: 'PDF / Doc',
            color: const Color(0xFFEC4899),
            onTap: () => _pickDocument(context),
          ),
          const SizedBox(width: 8),
          _AttachmentChip(
            icon: Icons.videocam_rounded,
            label: 'Video',
            color: const Color(0xFF8B5CF6),
            onTap: () => _pickVideo(context),
          ),
        ],
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
