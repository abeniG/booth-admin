import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:booth_admin/features/auth/auth_provider.dart';
import 'package:booth_admin/features/auth/login_screen.dart';
import 'package:booth_admin/shared/widgets/main_layout.dart';
import 'package:booth_admin/features/dashboard/dashboard_screen.dart';
import 'package:booth_admin/features/videos/videos_screen.dart';
import 'package:booth_admin/features/qr_codes/qr_codes_screen.dart';
import 'package:booth_admin/features/design_elements/screens/design_elements_screens.dart';
import 'package:booth_admin/features/printables/printables_screen.dart';
import 'package:booth_admin/features/price/price_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuth = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoggingIn = state.uri.path == '/admin/login';

      if (!isAuth && !isLoggingIn) {
        return '/admin/login';
      }

      if (isAuth && isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/videos',
            builder: (context, state) => const VideosScreen(),
          ),
          GoRoute(
            path: '/qr-codes',
            builder: (context, state) => const QRCodesScreen(),
          ),
          GoRoute(
            path: '/printables',
            builder: (context, state) => const PrintablesScreen(),
          ),
          GoRoute(
            path: '/price',
            builder: (context, state) => const PriceScreen(),
          ),
          GoRoute(
            path: '/design/stickers',
            builder: (context, state) => const StickersScreen(),
          ),
          GoRoute(
            path: '/design/backgrounds',
            builder: (context, state) => const BackgroundsScreen(),
          ),
          GoRoute(
            path: '/design/filters',
            builder: (context, state) => const FiltersScreen(),
          ),
          GoRoute(
            path: '/design/cover-pages',
            builder: (context, state) => const CoverPagesScreen(),
          ),
        ],
      ),
    ],
  );
});
