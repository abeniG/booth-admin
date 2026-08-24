import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:booth_admin/core/theme/app_theme.dart';
import 'package:booth_admin/models/cloudinary_resource.dart';
import 'package:booth_admin/services/cloudinary_provider.dart';

class VideosScreen extends ConsumerWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(cloudinaryVideosProvider);

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
                  Row(
                    children: [
                      const Text(
                        'Videos',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      videosAsync.maybeWhen(
                        data: (videos) => Chip(
                          label: Text(
                            '${videos.length}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                          backgroundColor: AppTheme.primary.withOpacity(0.12),
                          side: BorderSide.none,
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(LucideIcons.refreshCw, size: 18),
                        tooltip: 'Refresh',
                        onPressed: () =>
                            ref.invalidate(cloudinaryVideosProvider),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildToolbar(context),
                ],
              ),
            ),
            Expanded(
              child: videosAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => _ErrorWidget(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(cloudinaryVideosProvider),
                ),
                data: (videos) {
                  if (videos.isEmpty) {
                    return const _EmptyState(
                        message: 'No videos found in Cloudinary.');
                  }
                  return _VideosGrid(videos: videos);
                },
              ),
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
          child: const TextField(
            decoration: InputDecoration(
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
  final List<CloudinaryResource> videos;
  const _VideosGrid({required this.videos});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
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
          childAspectRatio: 1.0,
        ),
        itemCount: videos.length,
        itemBuilder: (context, index) => _VideoCard(video: videos[index]),
      );
    });
  }
}

class _VideoCard extends StatelessWidget {
  final CloudinaryResource video;
  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: video.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: Colors.black87,
                    child: const Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white54),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.black87,
                    child: const Icon(LucideIcons.video,
                        size: 40, color: Colors.white38),
                  ),
                ),
                const Center(
                  child: Icon(LucideIcons.playCircle,
                      size: 40, color: Colors.white70),
                ),
                if (video.duration != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.formattedDuration,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
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
                        video.publicId.split('/').last,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      video.formattedSize,
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, y').format(video.createdAt.toLocal()),
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.videoOff, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.cloudOff, size: 64, color: AppTheme.error),
            const SizedBox(height: 16),
            const Text(
              'Failed to load videos from Cloudinary',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              message.contains('YOUR_API_KEY')
                  ? 'Please set your API Key and Secret in cloudinary_service.dart'
                  : message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
