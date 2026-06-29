import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsServiceProvider = FutureProvider<SettingsService>((ref) async {
  final service = SettingsService();
  await service.initialize();
  return service;
});

class SettingsService {
  Future<void> initialize() async {
    // TODO: Initialize Hive boxes
  }

  Future<void> dispose() async {
    // TODO: Close Hive boxes
  }
}
