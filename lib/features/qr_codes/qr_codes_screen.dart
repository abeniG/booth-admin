import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:booth_admin/core/theme/app_theme.dart';

class QRCodesScreen extends StatelessWidget {
  const QRCodesScreen({super.key});

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
                    'QR Codes',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildToolbar(context),
                ],
              ),
            ),
            const Expanded(
              child: _QRCodesGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: ResponsiveLayout.isMobile(context) ? double.infinity : 300,
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Search ID or Photo ID...',
              prefixIcon: Icon(LucideIcons.search),
            ),
          ),
        ),
      ],
    );
  }
}

class _QRCodesGrid extends StatelessWidget {
  const _QRCodesGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (ResponsiveLayout.isMobile(context)) {
          crossAxisCount = 1; // single card stack on mobile
        } else if (ResponsiveLayout.isTablet(context)) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: ResponsiveLayout.isMobile(context) ? 2.5 : 1.3,
          ),
          itemCount: 16,
          itemBuilder: (context, index) {
            return const _QRCard();
          },
        );
      },
    );
  }
}

class _QRCard extends StatelessWidget {
  const _QRCard();

  @override
  Widget build(BuildContext context) {
    final bool isActive = true; // Placeholder

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // QR Code Placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.qrCode,
                  size: 48, color: Colors.black87),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.success.withOpacity(0.1)
                              : AppTheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isActive ? 'ACTIVE' : 'EXPIRED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isActive ? AppTheme.success : AppTheme.error,
                          ),
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton(
                        icon: const Icon(LucideIcons.moreVertical, size: 20),
                        padding: EdgeInsets.zero,
                        itemBuilder: (context) => [
                          const PopupMenuItem(child: Text('Download QR')),
                          const PopupMenuItem(child: Text('View Linked Photo')),
                          const PopupMenuItem(child: Text('Delete')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Photo ID: PHT-0391',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Generated: Today 14:32',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  Text('Expires: in 7 days',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
