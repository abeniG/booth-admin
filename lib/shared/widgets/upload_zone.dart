import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:booth_admin/core/theme/app_theme.dart';

class UploadZone extends StatelessWidget {
  final String label;
  final VoidCallback onSelectFile;

  const UploadZone(
      {super.key, required this.label, required this.onSelectFile});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    if (isMobile) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          foregroundColor: AppTheme.primary,
          elevation: 0,
        ),
        icon: const Icon(LucideIcons.uploadCloud),
        label: Text(label),
        onPressed: onSelectFile,
      );
    }

    return GestureDetector(
      onTap: onSelectFile,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: AppTheme.primary,
          strokeWidth: 2,
          dashPattern: const [8, 4],
          radius: const Radius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.uploadCloud,
                  size: 48, color: AppTheme.primary),
              const SizedBox(height: 16),
              const Text(
                'Drag & Drop Image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'or click to browse files',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
