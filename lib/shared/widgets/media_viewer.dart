import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:booth_admin/core/theme/app_theme.dart';

class MediaViewer extends StatelessWidget {
  final String title;
  final String metadata;

  const MediaViewer({
    super.key,
    required this.title,
    required this.metadata,
  });

  static void show(BuildContext context,
      {required String title, required String metadata}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding:
            EdgeInsets.all(ResponsiveLayout.isMobile(context) ? 0 : 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              ResponsiveLayout.isMobile(context) ? 0 : 16),
        ),
        child: MediaViewer(title: title, metadata: metadata),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isMobile(context)) {
      return _buildMobile(context);
    }
    return _buildDesktop(context);
  }

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        leading: CloseButton(onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(LucideIcons.download), onPressed: () {}),
          IconButton(
              icon: const Icon(LucideIcons.trash, color: AppTheme.error),
              onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.black87,
              child: const Icon(LucideIcons.image,
                  size: 64, color: Colors.white54),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            color: AppTheme.surface,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Metadata & Details',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                Text(metadata,
                    style: const TextStyle(fontSize: 14, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Container(
      width: 1200,
      height: 800,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Icon(LucideIcons.image,
                        size: 80, color: Colors.white54),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: AppTheme.surface,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      const Text('Details',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24)),
                      const SizedBox(height: 24),
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(metadata,
                          style: TextStyle(
                              color: AppTheme.textSecondary, height: 1.6)),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48)),
                        onPressed: () {},
                        icon: const Icon(LucideIcons.download),
                        label: const Text('Download Original'),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          foregroundColor: AppTheme.error,
                          side: const BorderSide(color: AppTheme.error),
                        ),
                        onPressed: () {},
                        icon: const Icon(LucideIcons.trash),
                        label: const Text('Delete Permanently'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(LucideIcons.x, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
