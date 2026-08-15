import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:booth_admin/core/theme/app_theme.dart';
import 'package:booth_admin/core/routing/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PhotoBoothAdminApp(),
    ),
  );
}

class PhotoBoothAdminApp extends ConsumerWidget {
  const PhotoBoothAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Photo Booth Admin',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
