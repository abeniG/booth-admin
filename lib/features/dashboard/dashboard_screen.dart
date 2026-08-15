import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:booth_admin/core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaxWidthContainer(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome back! Here is what\'s happening with the photo booth today.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _StatsGrid(),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Photos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(LucideIcons.arrowRight, size: 16),
                          label: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              sliver: _RecentPhotosGrid(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 6;
    if (ResponsiveLayout.isMobile(context)) {
      crossAxisCount = 2;
    } else if (ResponsiveLayout.isTablet(context)) {
      crossAxisCount = 3;
    }

    final stats = [
      {
        'title': 'Total Photos',
        'value': '1,248',
        'subtitle': '+12 today',
        'icon': LucideIcons.image
      },
      {
        'title': 'Total Videos',
        'value': '432',
        'subtitle': '+4 today',
        'icon': LucideIcons.video
      },
      {
        'title': 'Active QRs',
        'value': '84',
        'subtitle': 'Scanning now',
        'icon': LucideIcons.qrCode
      },
      {
        'title': 'Stickers',
        'value': '24',
        'subtitle': 'All active',
        'icon': LucideIcons.sticker
      },
      {
        'title': 'Backgrounds',
        'value': '12',
        'subtitle': '3 inactive',
        'icon': LucideIcons.image
      },
      {
        'title': 'Filters',
        'value': '8',
        'subtitle': 'Preset styles',
        'icon': LucideIcons.sparkles
      },
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: stats.map((stat) {
        return SizedBox(
          width: _getCardWidth(context, crossAxisCount),
          child: _StatCard(
            title: stat['title'] as String,
            value: stat['value'] as String,
            subtitle: stat['subtitle'] as String,
            icon: stat['icon'] as IconData,
          ),
        );
      }).toList(),
    );
  }

  double _getCardWidth(BuildContext context, int columns) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = 48; // 24 on each side
    double navWidth = 0;

    // account for navigation bars roughly
    if (ResponsiveLayout.isDesktop(context)) {
      navWidth = 250;
      screenWidth = screenWidth > 1600 ? 1600 : screenWidth; // max width
    } else if (ResponsiveLayout.isTablet(context)) {
      navWidth = 80;
    }

    double availableWidth = screenWidth - padding - navWidth;
    double spacing = 16 * (columns - 1);

    return ((availableWidth - spacing) / columns).floorToDouble();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(icon, size: 20, color: AppTheme.primary.withOpacity(0.8)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: title.contains('Total Photos')
                    ? AppTheme.success
                    : AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentPhotosGrid extends StatelessWidget {
  const _RecentPhotosGrid();

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 5;
        if (ResponsiveLayout.isMobile(context)) {
          crossAxisCount = 2; // Mobile specifies 2-column grid or list
        } else if (ResponsiveLayout.isTablet(context)) {
          crossAxisCount = 3;
        }

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8, // Slightly taller for info
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return const _PhotoCardPlaceholder();
            },
            childCount: 10,
          ),
        );
      },
    );
  }
}

class _PhotoCardPlaceholder extends StatelessWidget {
  const _PhotoCardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: Colors.grey.shade200,
              child:
                  const Icon(LucideIcons.image, size: 48, color: Colors.grey),
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
                      'Just now',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const Icon(LucideIcons.checkCircle2,
                        size: 14, color: AppTheme.success),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.eye, size: 16),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.download, size: 16),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.qrCode, size: 16),
                      onPressed: () {},
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
