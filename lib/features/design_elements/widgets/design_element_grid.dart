import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:booth_admin/core/theme/app_theme.dart';
import 'package:booth_admin/services/design_asset_service.dart';

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
    return StreamBuilder<List<DesignAsset>>(
      stream: DesignAssetService.streamAssets(itemType),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Failed to load $title.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final assets = snapshot.data!;
        if (assets.isEmpty) {
          return Center(child: Text('No $title uploaded yet.'));
        }

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
              itemCount: assets.length,
              itemBuilder: (context, index) {
                return _DesignElementCard(
                  type: itemType,
                  asset: assets[index],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _DesignElementCard extends StatelessWidget {
  final String type;
  final DesignAsset asset;
  const _DesignElementCard({required this.type, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _AssetImage(url: asset.url),
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
                        asset.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Switch(
                      value: asset.enabled,
                      onChanged: (val) => DesignAssetService.updateEnabled(
                        type,
                        asset.id,
                        val,
                      ),
                      activeThumbColor: AppTheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      asset.enabled ? 'Active' : 'Inactive',
                      style: TextStyle(
                          fontSize: 12,
                          color: asset.enabled
                              ? AppTheme.success
                              : AppTheme.error),
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
                          onPressed: () => DesignAssetService.deleteAsset(
                            type,
                            asset.id,
                          ),
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

class _AssetImage extends StatelessWidget {
  final String url;

  const _AssetImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return _imagePlaceholder();
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            _imagePlaceholder(),
            const Center(child: CircularProgressIndicator()),
          ],
        );
      },
      errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Icon(LucideIcons.imageOff, size: 40, color: Colors.grey),
      ),
    );
  }
}
