import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/storage/database_service.dart';
import 'core/storage/settings_service.dart';

class YTMusicApp extends ConsumerStatefulWidget {
  const YTMusicApp({super.key});

  @override
  ConsumerState<YTMusicApp> createState() => _YTMusicAppState();
}

class _YTMusicAppState extends ConsumerState<YTMusicApp> {
  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    ref.read(databaseServiceProvider.future);
    ref.read(settingsServiceProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = ref.watch(appThemeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'YTMusic',
      debugShowCheckedModeBanner: false,
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
