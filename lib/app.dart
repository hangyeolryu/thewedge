import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/services/deeplink_service.dart';
import 'core/theme/app_theme.dart';

class TheWedgeApp extends ConsumerStatefulWidget {
  const TheWedgeApp({super.key});

  @override
  ConsumerState<TheWedgeApp> createState() => _TheWedgeAppState();
}

class _TheWedgeAppState extends ConsumerState<TheWedgeApp> {
  final _deeplinkService = DeeplinkService();

  @override
  void initState() {
    super.initState();
    // Initialize deeplinks after the first frame so router is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(routerProvider);
      _deeplinkService.initialize(router);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'TheWedge · 더 왜지?',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
    );
  }
}
