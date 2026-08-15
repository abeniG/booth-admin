import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:booth_admin/core/theme/app_theme.dart';

class DesignElementGrid extends StatelessWidget {
  final String title;
  final String itemType;
  final VoidCallback onUploadPressed;

  const DesignElementGrid({
    super.key,
    required this.title,
    required this.itemType,
    required this.onUploadPressed,
  });

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: onUploadPressed,
                        icon: const Icon(LucideIcons.plus),
                        label: Text('Upload $itemType'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: ResponsiveLayout.isMobile(context)
                        ? double.infinity
                        : 300,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search $title...',
                        prefixIcon: const Icon(LucideIcons.search),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildGrid(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
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
          itemCount: 10,
          itemBuilder: (context, index) {
            return _DesignElementCard(type: itemType, index: index);
          },
        );
      },
    );
  }
}

class _DesignElementCard extends StatelessWidget {
  final String type;
  final int index;
  const _DesignElementCard({required this.type, required this.index});

  @override
  Widget build(BuildContext context) {
    bool isActive = index % 3 != 0; // Just mock data

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              // Background pattern indicating transparency
              child: const Center(
                child: Icon(LucideIcons.image, size: 48, color: Colors.grey),
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
                    Expanded(
                      child: Text(
                        '${type}_$index',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Switch(
                      value: isActive,
                      onChanged: (val) {},
                      activeColor: AppTheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                          fontSize: 12,
                          color: isActive ? AppTheme.success : AppTheme.error),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.edit2, size: 16),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(minWidth: 28, minHeight: 28),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.trash,
                              size: 16, color: AppTheme.error),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(minWidth: 28, minHeight: 28),
                        ),
                      ],
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
