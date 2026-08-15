import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:booth_admin/core/theme/app_theme.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  bool isGridView = true;

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
                    'Photos',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildToolbar(context),
                ],
              ),
            ),
            Expanded(
              child: isGridView ? const _PhotosGrid() : const _PhotosList(),
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
          onSelected: (value) {},
        ),
        DropdownMenu<String>(
          initialSelection: 'All Status',
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: 'All Status', label: 'All Status'),
            DropdownMenuEntry(value: 'Has QR', label: 'Has QR'),
            DropdownMenuEntry(value: 'No QR', label: 'No QR'),
          ],
          onSelected: (value) {},
        ),
        const Spacer(),
        // Grid / List Toggle
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, icon: Icon(LucideIcons.grid)),
            ButtonSegment(value: false, icon: Icon(LucideIcons.list)),
          ],
          selected: {isGridView},
          onSelectionChanged: (Set<bool> newSelection) {
            setState(() {
              isGridView = newSelection.first;
            });
          },
        ),
      ],
    );
  }
}

class _PhotosGrid extends StatelessWidget {
  const _PhotosGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
          itemCount: 20,
          itemBuilder: (context, index) {
            return _PhotoCard(index: index);
          },
        );
      },
    );
  }
}

class _PhotosList extends StatelessWidget {
  const _PhotosList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: 20,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade200,
            child: const Icon(LucideIcons.image, color: Colors.grey),
          ),
          title: Text('Photo_IMG_${index}_0391.png'),
          subtitle: const Text('Captured today at 14:32 • QR Active'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: () {}, icon: const Icon(LucideIcons.eye)),
              IconButton(
                  onPressed: () {}, icon: const Icon(LucideIcons.download)),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.trash, color: AppTheme.error)),
            ],
          ),
        );
      },
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final int index;
  const _PhotoCard({required this.index});

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
                      'Today 14:32',
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
                      tooltip: 'View Photo',
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.download, size: 16),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Download',
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.qrCode, size: 16),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Open QR',
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.trash,
                          size: 16, color: AppTheme.error),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Delete',
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
