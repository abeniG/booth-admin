import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:booth_admin/core/responsive/responsive_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:booth_admin/core/theme/app_theme.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileLayout(child: child),
      tablet: _TabletLayout(child: child),
      desktop: _DesktopLayout(child: child),
    );
  }
}

final List<_NavItem> _navItems = [
  _NavItem(
      label: 'Dashboard',
      icon: LucideIcons.layoutDashboard,
      path: '/dashboard'),
  _NavItem(label: 'Photos', icon: LucideIcons.image, path: '/photos'),
  _NavItem(label: 'Videos', icon: LucideIcons.video, path: '/videos'),
  _NavItem(label: 'QR Codes', icon: LucideIcons.qrCode, path: '/qr-codes'),
  _NavItem(
      label: 'Stickers', icon: LucideIcons.sticker, path: '/design/stickers'),
  _NavItem(
      label: 'Backgrounds',
      icon: LucideIcons.image,
      path: '/design/backgrounds'),
  _NavItem(
      label: 'Filters', icon: LucideIcons.sparkles, path: '/design/filters'),
];

class _NavItem {
  final String label;
  final IconData icon;
  final String path;

  _NavItem({required this.label, required this.icon, required this.path});
}

class _MobileLayout extends StatelessWidget {
  final Widget child;
  const _MobileLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tizita Studio',
          style: GoogleFonts.alexBrush(
            fontSize: 28,
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const _DrawerHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _navItems.map((item) {
                  return ListTile(
                    leading: Icon(item.icon),
                    title: Text(item.label),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      context.go(item.path);
                    },
                    selected: GoRouterState.of(context)
                        .uri
                        .path
                        .startsWith(item.path),
                    selectedColor: AppTheme.primary,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final Widget child;
  const _TabletLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final selectedIndex =
        _navItems.indexWhere((i) => currentPath.startsWith(i.path));

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex == -1 ? 0 : selectedIndex,
            onDestinationSelected: (index) {
              context.go(_navItems[index].path);
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppTheme.surface,
            selectedIconTheme: const IconThemeData(color: AppTheme.primary),
            selectedLabelTextStyle: const TextStyle(
                color: AppTheme.primary, fontWeight: FontWeight.bold),
            destinations: _navItems.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.icon, color: AppTheme.primary),
                label: Text(item.label, style: const TextStyle(fontSize: 11)),
              );
            }).toList(),
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child:
                  Icon(LucideIcons.camera, size: 32, color: AppTheme.primary),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final Widget child;
  const _DesktopLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 250,
            color: AppTheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DrawerHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: _navItems.map((item) {
                      final isSelected = GoRouterState.of(context)
                          .uri
                          .path
                          .startsWith(item.path);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          leading: Icon(item.icon,
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary),
                          title: Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          tileColor: isSelected
                              ? AppTheme.primary.withOpacity(0.1)
                              : null,
                          onTap: () {
                            context.go(item.path);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      color: AppTheme.surface,
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.camera, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tizita\nStudio',
              style: GoogleFonts.alexBrush(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
