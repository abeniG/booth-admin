// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:booth_admin/core/theme/app_theme.dart';
import 'package:booth_admin/models/cloudinary_resource.dart';
import 'package:booth_admin/services/cloudinary_provider.dart';
import 'package:booth_admin/services/cloudinary_service.dart';

class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key});

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen> {
  bool isGridView = true;
  String _searchQuery = '';
  String _dateFilter = 'All Dates';

  List<CloudinaryResource> _applyFilters(List<CloudinaryResource> all) {
    final now = DateTime.now();
    return all.where((r) {
      // Search filter
      if (_searchQuery.isNotEmpty &&
          !r.publicId.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      // Date filter
      if (_dateFilter == 'Today') {
        return r.createdAt.year == now.year &&
            r.createdAt.month == now.month &&
            r.createdAt.day == now.day;
      }
      if (_dateFilter == 'Yesterday') {
        final yesterday = now.subtract(const Duration(days: 1));
        return r.createdAt.year == yesterday.year &&
            r.createdAt.month == yesterday.month &&
            r.createdAt.day == yesterday.day;
      }
      if (_dateFilter == 'Last 7 Days') {
        return r.createdAt.isAfter(now.subtract(const Duration(days: 7)));
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(cloudinaryPhotosProvider);

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
                        'Photos',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      photosAsync.when(
                        data: (photos) => Chip(
                          label: Text(
                            '${photos.length}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                          backgroundColor: AppTheme.primary.withOpacity(0.12),
                          side: BorderSide.none,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(LucideIcons.refreshCw, size: 18),
                        tooltip: 'Refresh',
                        onPressed: () =>
                            ref.invalidate(cloudinaryPhotosProvider),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildToolbar(context),
                ],
              ),
            ),
            Expanded(
              child: photosAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => _ErrorWidget(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(cloudinaryPhotosProvider),
                ),
                data: (photos) {
                  final filtered = _applyFilters(photos);
                  if (filtered.isEmpty) {
                    return const _EmptyState(
                        message: 'No photos found. Adjust your filters.');
                  }
                  return isGridView
                      ? _PhotosGrid(photos: filtered)
                      : _PhotosList(photos: filtered);
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
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search photos...',
              prefixIcon: Icon(LucideIcons.search),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        DropdownMenu<String>(
          initialSelection: 'All Dates',
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: 'All Dates', label: 'All Dates'),
            DropdownMenuEntry(value: 'Today', label: 'Today'),
            DropdownMenuEntry(value: 'Yesterday', label: 'Yesterday'),
            DropdownMenuEntry(value: 'Last 7 Days', label: 'Last 7 Days'),
          ],
          onSelected: (value) =>
              setState(() => _dateFilter = value ?? 'All Dates'),
        ),
        // Removed Spacer() here because Wrap cannot have Expanded/Spacer children
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, icon: Icon(LucideIcons.grid)),
            ButtonSegment(value: false, icon: Icon(LucideIcons.list)),
          ],
          selected: {isGridView},
          onSelectionChanged: (Set<bool> s) =>
              setState(() => isGridView = s.first),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PhotosGrid extends StatelessWidget {
  final List<CloudinaryResource> photos;
  const _PhotosGrid({required this.photos});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount = 6;
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
          childAspectRatio: 0.8,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) => _PhotoCard(photo: photos[index]),
      );
    });
  }
}

class _PhotosList extends StatelessWidget {
  final List<CloudinaryResource> photos;
  const _PhotosList({required this.photos});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: photos.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final photo = photos[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: photo.secureUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(width: 60, height: 60, color: Colors.grey.shade200),
              errorWidget: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
                child: const Icon(LucideIcons.image, color: Colors.grey),
              ),
            ),
          ),
          title: Text(
            photo.publicId.split('/').last,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${DateFormat('MMM d, y • HH:mm').format(photo.createdAt.toLocal())}  •  ${photo.formattedSize}',
          ),
          trailing: _PhotoActions(photo: photo),
        );
      },
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final CloudinaryResource photo;
  const _PhotoCard({required this.photo});

  @override
  Widget build(BuildContext context) {
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
                        DateFormat('MMM d, HH:mm')
                            .format(photo.createdAt.toLocal()),
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      photo.formattedSize,
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _PhotoActions(photo: photo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoActions extends ConsumerWidget {
  final CloudinaryResource photo;
  const _PhotoActions({required this.photo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── View ──────────────────────────────────────────────────────────────
        IconButton(
          icon: const Icon(LucideIcons.eye, size: 16),
          tooltip: 'View Photo',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () => html.window.open(photo.secureUrl, '_blank'),
        ),
        // ── Download ──────────────────────────────────────────────────────────
        IconButton(
          icon: const Icon(LucideIcons.download, size: 16),
          tooltip: 'Download',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () {
            // fl_attachment forces a browser download instead of a preview
            final downloadUrl = photo.secureUrl
                .replaceFirst('/upload/', '/upload/fl_attachment/');
            html.window.open(downloadUrl, '_blank');
          },
        ),
        // ── Delete ────────────────────────────────────────────────────────────
        IconButton(
          icon: const Icon(LucideIcons.trash, size: 16, color: AppTheme.error),
          tooltip: 'Delete',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () => _confirmDelete(context, ref),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photo'),
        content: Text(
          'Are you sure you want to permanently delete\n"${photo.publicId.split('/').last}"?\n\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await CloudinaryService.deleteResource(
          photo.publicId, photo.resourceType);
      // Refresh both photos and stats
      ref.invalidate(cloudinaryPhotosProvider);
      ref.invalidate(cloudinaryStatsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo deleted successfully.'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.imageOff, size: 64, color: Colors.grey.shade400),
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
              'Failed to load from Cloudinary',
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
