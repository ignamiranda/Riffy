import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _authBoxName = 'auth';

final settingsServiceProvider = FutureProvider<SettingsService>((ref) async {
  final service = SettingsService();
  await service.initialize();
  return service;
});

class SettingsService {
  late Box _authBox;

  Future<void> initialize() async {
    // Hive.initFlutter() called in main() before runApp()
    _authBox = await Hive.openBox(_authBoxName);
  }

  String? get accessToken => _authBox.get('accessToken') as String?;

  Future<void> setAccessToken(String? token) async {
    if (token != null) {
      await _authBox.put('accessToken', token);
    } else {
      await _authBox.delete('accessToken');
    }
  }

  Future<void> dispose() async {
    await _authBox.close();
  }
}
