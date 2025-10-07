import 'attendance.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceRecord>> getAll();
  Future<List<AttendanceRecord>> getByMember(String memberId);
  Future<void> create(AttendanceRecord r);
}
