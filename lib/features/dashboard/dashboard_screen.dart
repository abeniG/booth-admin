import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:booth_admin/core/theme/app_theme.dart';
import 'package:booth_admin/models/saved_media.dart';
import 'package:booth_admin/services/saved_media_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaxWidthContainer(
      child: Scaffold(
        body: StreamBuilder<List<SavedMedia>>(
          stream: SavedMediaService.streamSavedMedia(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Text('Failed to load saved media: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final media = snapshot.data!;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Overview',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text(
                          'Welcome back! Here is what\'s happening with the photo booth today.',
                          style: TextStyle(
                              fontSize: 16, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 32),
                        _StatsGrid(media: media),
                        const SizedBox(height: 48),
                        const Text('Recent Photos',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (media.isEmpty)
                  const SliverFillRemaining(
                      child: Center(child: Text('No saved images found.')))
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: _SavedMediaGrid(media: media.take(10).toList()),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<SavedMedia> media;

  const _StatsGrid({required this.media});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int columns = screenWidth >= 1500 ? 5 : 4;
    if (ResponsiveLayout.isMobile(context)) columns = 2;
    if (ResponsiveLayout.isTablet(context)) columns = 3;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _StatCard(
            title: 'Total Photos',
            value: '${media.length}',
            icon: LucideIcons.image),
        _StatCard(
            title: 'Total Videos',
            value: '${media.where((item) => item.videoUrl.isNotEmpty).length}',
            icon: LucideIcons.video),
      ].map((card) {
        return SizedBox(width: _cardWidth(context, columns), child: card);
      }).toList(),
    );
  }

  double _cardWidth(BuildContext context, int columns) {
    var width = MediaQuery.of(context).size.width;
    final navWidth = ResponsiveLayout.isDesktop(context)
        ? 250
        : ResponsiveLayout.isTablet(context)
            ? 80
            : 0;
    width = width > 1600 && ResponsiveLayout.isDesktop(context) ? 1600 : width;
    return ((width - navWidth - 48 - 16 * (columns - 1)) / columns)
        .floorToDouble();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 12),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Icon(icon, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}

class _SavedMediaGrid extends StatelessWidget {
  final List<SavedMedia> media;

  const _SavedMediaGrid({required this.media});

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        var columns = 5;
        if (ResponsiveLayout.isMobile(context)) columns = 2;
        if (ResponsiveLayout.isTablet(context)) columns = 3;
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _SavedMediaCard(media: media[index]),
            childCount: media.length,
          ),
        );
      },
    );
  }
}

class _SavedMediaCard extends StatelessWidget {
  final SavedMedia media;

  const _SavedMediaCard({required this.media});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: media.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  const Center(child: Icon(LucideIcons.imageOff, size: 48)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(DateFormat('MMM d, y').format(media.createdAt.toLocal()),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      tooltip: 'View image',
                      icon: const Icon(LucideIcons.eye, size: 16),
                      onPressed: () => _view(context),
                    ),
                    IconButton(
                      tooltip: 'Download image and video',
                      icon: const Icon(LucideIcons.download, size: 16),
                      onPressed: () => _download(context),
                    ),
                    IconButton(
                      tooltip: 'Generate QR code',
                      icon: const Icon(LucideIcons.qrCode, size: 16),
                      onPressed: () => _showQr(context),
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

  void _view(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.network(media.imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Future<void> _download(BuildContext context) async {
    final urls = [
      media.imageUrl,
      if (media.videoUrl.isNotEmpty) media.videoUrl
    ];
    for (final url in urls) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download links opened.')));
    }
  }

  void _showQr(BuildContext context) {
    final videoQuery = media.videoUrl.isEmpty
        ? ''
        : '&videoUrl=${Uri.encodeComponent(media.videoUrl)}';
    final landingUrl =
        'https://photo-booth-landing.abenikeradio.workers.dev/?url=${Uri.encodeComponent(media.imageUrl)}$videoQuery';

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan to view media'),
        content: SizedBox(
          width: 260,
          child: QrImageView(data: landingUrl, size: 240),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }
}
