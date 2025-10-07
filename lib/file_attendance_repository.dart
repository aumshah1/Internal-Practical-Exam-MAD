import 'dart:async';

import 'package:flutter/foundation.dart';

import 'attendance.dart';
import 'file_storage.dart';
import 'id_generator.dart';
import 'attendance_repository.dart';

class FileAttendanceRepository extends ChangeNotifier implements AttendanceRepository {
  final FileStorageService _storage;
  final String _file = 'attendance.json';
  final List<AttendanceRecord> _cache = [];

  FileAttendanceRepository(this._storage);

  Future<void> load() async {
    final list = await _storage.readList(_file);
    _cache.clear();
    for (final e in list) {
      try {
        _cache.add(AttendanceRecord.fromJson(e));
      } catch (ignored) {
        if (kDebugMode) print('failed parse attendance: $ignored');
      }
    }
    notifyListeners();
  }

  @override
  Future<List<AttendanceRecord>> getAll() async => List.from(_cache);

  @override
  Future<List<AttendanceRecord>> getByMember(String memberId) async => _cache.where((r) => r.memberId == memberId).toList();

  Future<void> _persist() async {
    final jsonList = _cache.map((r) => r.toJson()).toList();
    await _storage.writeList(_file, jsonList);
  }

  @override
  Future<void> create(AttendanceRecord r) async {
    final rec = AttendanceRecord(id: r.id.isEmpty ? generateId() : r.id, memberId: r.memberId, at: r.at, note: r.note);
    _cache.add(rec);
    await _persist();
    notifyListeners();
  }
}
