// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:booth_admin/core/theme/app_theme.dart';
import 'package:booth_admin/models/uploaded_photo.dart';
import 'package:booth_admin/services/cloudinary_provider.dart';
import 'package:booth_admin/services/uploaded_photo_service.dart';

class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key});

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen> {
  bool isGridView = true;
  String _searchQuery = '';
  String _dateFilter = 'All Dates';

  List<UploadedPhoto> _applyFilters(List<UploadedPhoto> photos) {
    final now = DateTime.now();
    return photos.where((photo) {
      if (_searchQuery.isNotEmpty &&
          !photo.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_dateFilter == 'Today') return _sameDay(photo.createdAt, now);
      if (_dateFilter == 'Yesterday') {
        return _sameDay(photo.createdAt, now.subtract(const Duration(days: 1)));
      }
      if (_dateFilter == 'Last 7 Days') {
        return photo.createdAt.isAfter(now.subtract(const Duration(days: 7)));
      }
      return true;
    }).toList();
  }

  bool _sameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(uploadedPhotosProvider);
    return MaxWidthContainer(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Photos',
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      photosAsync.when(
                        data: (photos) => Chip(label: Text('${photos.length}')),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(LucideIcons.refreshCw, size: 18),
                        tooltip: 'Refresh',
                        onPressed: () => ref.invalidate(uploadedPhotosProvider),
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
                error: (error, _) => _ErrorWidget(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(uploadedPhotosProvider),
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
      children: [
        SizedBox(
          width: isMobile ? double.infinity : 300,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search photos...',
              prefixIcon: Icon(LucideIcons.search),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
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
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, icon: Icon(LucideIcons.grid)),
            ButtonSegment(value: false, icon: Icon(LucideIcons.list)),
          ],
          selected: {isGridView},
          onSelectionChanged: (selection) =>
              setState(() => isGridView = selection.first),
        ),
      ],
    );
  }
}

class _PhotosGrid extends StatelessWidget {
  final List<UploadedPhoto> photos;
  const _PhotosGrid({required this.photos});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      int columns = 6;
      if (ResponsiveLayout.isMobile(context)) {
        columns = 2;
      } else if (ResponsiveLayout.isTablet(context)) {
        columns = 3;
      } else if (constraints.maxWidth < 1200) {
        columns = 4;
      }
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
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
  final List<UploadedPhoto> photos;
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
          leading: _PhotoImage(url: photo.url, width: 60, height: 60),
          title: Text(photo.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
              '${DateFormat('MMM d, y • HH:mm').format(photo.createdAt.toLocal())}  •  ${photo.formattedSize}'),
          trailing: _PhotoActions(photo: photo),
        );
      },
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final UploadedPhoto photo;
  const _PhotoCard({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _PhotoImage(url: photo.url)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(photo.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                    DateFormat('MMM d, HH:mm')
                        .format(photo.createdAt.toLocal()),
                    style:
                        TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                _PhotoActions(photo: photo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  const _PhotoImage({required this.url, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (_, __, ___) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        child: const Icon(LucideIcons.imageOff, color: Colors.grey),
      ),
    );
  }
}

class _PhotoActions extends ConsumerWidget {
  final UploadedPhoto photo;
  const _PhotoActions({required this.photo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(LucideIcons.eye, size: 16),
          tooltip: 'View Photo',
          onPressed: () => html.window.open(photo.url, '_blank'),
        ),
        IconButton(
          icon: const Icon(LucideIcons.download, size: 16),
          tooltip: 'Download',
          onPressed: () => html.window.open(photo.url, '_blank'),
        ),
        IconButton(
          icon: const Icon(LucideIcons.trash, size: 16, color: AppTheme.error),
          tooltip: 'Delete',
          onPressed: () => _delete(context, ref),
        ),
      ],
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Photo'),
        content: Text('Delete "${photo.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await UploadedPhotoService.deletePhoto(photo.id);
      ref.invalidate(uploadedPhotosProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Delete failed: $error')));
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) => Center(child: Text(message));
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.cloudOff, size: 56, color: AppTheme.error),
          const SizedBox(height: 12),
          const Text('Failed to load photos from Firestore'),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
