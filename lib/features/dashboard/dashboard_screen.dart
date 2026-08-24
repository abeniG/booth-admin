import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:booth_admin/core/theme/app_theme.dart';
import 'package:booth_admin/models/cloudinary_resource.dart';
import 'package:booth_admin/services/cloudinary_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(cloudinaryPhotosProvider);
    final videosAsync = ref.watch(cloudinaryVideosProvider);

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
                    // ── Stats ──────────────────────────────────────────────────
                    _StatsGrid(
                      photosAsync: photosAsync,
                      videosAsync: videosAsync,
                    ),
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
            // ── Recent Photos ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: photosAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => SliverToBoxAdapter(
                  child: _InlineError(message: err.toString()),
                ),
                data: (photos) => _RecentPhotosGrid(
                  photos: photos.take(10).toList(),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final AsyncValue<List<CloudinaryResource>> photosAsync;
  final AsyncValue<List<CloudinaryResource>> videosAsync;

  const _StatsGrid({
    required this.photosAsync,
    required this.videosAsync,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth >= 1500 ? 6 : 4;
    if (ResponsiveLayout.isMobile(context)) {
      crossAxisCount = 2;
    } else if (ResponsiveLayout.isTablet(context)) {
      crossAxisCount = 3;
    }

    final photoCount =
        photosAsync.maybeWhen(data: (p) => '${p.length}', orElse: () => '—');
    final videoCount =
        videosAsync.maybeWhen(data: (v) => '${v.length}', orElse: () => '—');

    // Count how many photos were captured today
    final todayCount = photosAsync.maybeWhen(
      data: (p) {
        final today = DateTime.now();
        return p
            .where((r) =>
                r.createdAt.year == today.year &&
                r.createdAt.month == today.month &&
                r.createdAt.day == today.day)
            .length;
      },
      orElse: () => 0,
    );

    final stats = [
      {
        'title': 'Total Photos',
        'value': photoCount,
        'subtitle': todayCount > 0 ? '+$todayCount today' : 'From Cloudinary',
        'icon': LucideIcons.image,
        'loading': photosAsync.isLoading,
      },
      {
        'title': 'Total Videos',
        'value': videoCount,
        'subtitle': 'From Cloudinary',
        'icon': LucideIcons.video,
        'loading': videosAsync.isLoading,
      },
      {
        'title': 'Active QRs',
        'value': '—',
        'subtitle': 'Coming soon',
        'icon': LucideIcons.qrCode,
        'loading': false,
      },
      {
        'title': 'Stickers',
        'value': '—',
        'subtitle': 'Manage in Design',
        'icon': LucideIcons.sticker,
        'loading': false,
      },
      {
        'title': 'Backgrounds',
        'value': '—',
        'subtitle': 'Manage in Design',
        'icon': LucideIcons.image,
        'loading': false,
      },
      {
        'title': 'Filters',
        'value': '—',
        'subtitle': 'Preset styles',
        'icon': LucideIcons.sparkles,
        'loading': false,
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
            isLoading: stat['loading'] as bool,
          ),
        );
      }).toList(),
    );
  }

  double _getCardWidth(BuildContext context, int columns) {
    double screenWidth = MediaQuery.of(context).size.width;
    const double padding = 48;
    double navWidth = 0;
    if (ResponsiveLayout.isDesktop(context)) {
      navWidth = 250;
      screenWidth = screenWidth > 1600 ? 1600 : screenWidth;
    } else if (ResponsiveLayout.isTablet(context)) {
      navWidth = 80;
    }
    final double availableWidth = screenWidth - padding - navWidth;
    final double spacing = 16 * (columns - 1);
    return ((availableWidth - spacing) / columns).floorToDouble();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final bool isLoading;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.isLoading,
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
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, size: 20, color: AppTheme.primary.withOpacity(0.8)),
              ],
            ),
            const SizedBox(height: 16),
            isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
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
                color: subtitle.contains('today') && !subtitle.contains('0')
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

// ─────────────────────────────────────────────────────────────────────────────

class _RecentPhotosGrid extends StatelessWidget {
  final List<CloudinaryResource> photos;
  const _RecentPhotosGrid({required this.photos});

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 5;
        if (ResponsiveLayout.isMobile(context)) crossAxisCount = 2;
        if (ResponsiveLayout.isTablet(context)) crossAxisCount = 3;

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _RecentPhotoCard(photo: photos[index]),
            childCount: photos.length,
          ),
        );
      },
    );
  }
}

class _RecentPhotoCard extends StatelessWidget {
  final CloudinaryResource photo;
  const _RecentPhotoCard({required this.photo});

  @override
  Widget build(BuildContext context) {
    final isToday = () {
      final now = DateTime.now();
      return photo.createdAt.year == now.year &&
          photo.createdAt.month == now.month &&
          photo.createdAt.day == now.day;
    }();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: photo.secureUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child:
                    const Icon(LucideIcons.image, size: 48, color: Colors.grey),
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
                    Flexible(
                      child: Text(
                        isToday
                            ? DateFormat('HH:mm')
                                .format(photo.createdAt.toLocal())
                            : DateFormat('MMM d')
                                .format(photo.createdAt.toLocal()),
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle, color: AppTheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message.contains('YOUR_API_KEY')
                  ? 'Set your Cloudinary API Key & Secret in cloudinary_service.dart'
                  : 'Could not load photos: $message',
              style: const TextStyle(color: AppTheme.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
