import 'package:flutter/material.dart';
import '../repositories/file_member_repository.dart';
import '../services/file_storage_service.dart';

class AppState extends ChangeNotifier {
  final FileStorageService storage = FileStorageService();
  late final FileMemberRepository memberRepo;

  bool _initialized = false;
  bool get initialized => _initialized;

  AppState() {
    memberRepo = FileMemberRepository(storage);
  }

  Future<void> init() async {
    await storage.init();
    await memberRepo.load();
    _initialized = true;
    notifyListeners();
  }
}
