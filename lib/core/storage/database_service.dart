import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseServiceProvider = FutureProvider<DatabaseService>((ref) async {
  final service = DatabaseService();
  await service.initialize();
  return service;
});

class DatabaseService {
  Future<void> initialize() async {
    // TODO: Initialize drift database
  }

  Future<void> dispose() async {
    // TODO: Close drift database
  }
}
