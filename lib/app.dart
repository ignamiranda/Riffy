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
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initServices();
    });
  }

  Future<void> _initServices() async {
    await ref.read(databaseServiceProvider.future);
    await ref.read(settingsServiceProvider.future);
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

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
