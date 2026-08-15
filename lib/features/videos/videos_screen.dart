import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:booth_admin/core/theme/app_theme.dart';

class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaxWidthContainer(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Videos',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildToolbar(context),
                ],
              ),
            ),
            const Expanded(
              child: _VideosGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: isMobile ? double.infinity : 300,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search videos...',
              prefixIcon: Icon(LucideIcons.search),
            ),
          ),
        ),
      ],
    );
  }
}

class _VideosGrid extends StatelessWidget {
  const _VideosGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 5;
        if (ResponsiveLayout.isMobile(context)) {
          crossAxisCount = 2;
        } else if (ResponsiveLayout.isTablet(context)) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 4;
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0, // Videos tend to be wider or 1:1
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            return const _VideoCard();
          },
        );
      },
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: Colors.black87,
              child: const Center(
                child: Icon(LucideIcons.playCircle,
                    size: 48, color: Colors.white70),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            color: AppTheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '00:15 sec',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary),
                    ),
                    Text(
                      '12 MB',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.play, size: 16),
                      onPressed: () {},
                      tooltip: 'Preview',
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.download, size: 16),
                      onPressed: () {},
                      tooltip: 'Download',
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.trash,
                          size: 16, color: AppTheme.error),
                      onPressed: () {},
                      tooltip: 'Delete',
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
