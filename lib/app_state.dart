import 'package:flutter/material.dart';
import 'file_member_repository.dart';
import 'file_payment_repository.dart';
import 'file_attendance_repository.dart';
import 'file_membership_plan_repository.dart';
import 'file_storage.dart';

class AppState extends ChangeNotifier {
  final FileStorageService storage = FileStorageService();
  late final FileMemberRepository memberRepo;
  late final FilePaymentRepository paymentRepo;
  late final FileAttendanceRepository attendanceRepo;
  late final FileMembershipPlanRepository planRepo;

  bool _initialized = false;
  bool get initialized => _initialized;
  String? initError;

  AppState() {
    memberRepo = FileMemberRepository(storage);
    paymentRepo = FilePaymentRepository(storage);
    attendanceRepo = FileAttendanceRepository(storage);
  planRepo = FileMembershipPlanRepository(storage);
  }

  Future<void> init() async {
    try {
      await storage.init();
  await memberRepo.load();
  await paymentRepo.load();
  await attendanceRepo.load();
  await planRepo.load();
    } catch (e, st) {
      initError = '$e\n$st';
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }
}
