import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/member.dart';
import 'member_repository.dart';
import '../services/file_storage_service.dart';
import '../utils/id_generator.dart';
import '../utils/date_utils.dart';

class FileMemberRepository extends ChangeNotifier implements MemberRepository {
  final FileStorageService _storage;
  final String _file = 'members.json';
  final List<Member> _cache = [];

  FileMemberRepository(this._storage);

  Future<void> load() async {
    final list = await _storage.readList(_file);
    _cache.clear();
    for (final e in list) {
      try {
        _cache.add(Member.fromJson(e));
      } catch (ignored) {}
    }
    notifyListeners();
  }

  List<Member> _visible(bool includeInactive) => includeInactive ? List.from(_cache) : _cache.where((m) => m.active).toList();

  @override
  @override
  Future<List<Member>> getAll({bool includeInactive = false}) async {
    return _visible(includeInactive);
  }

  @override
  Future<Member?> getById(String id) async {
    try {
      return _cache.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _persist() async {
    final jsonList = _cache.map((m) => m.toJson()).toList();
    await _storage.writeList(_file, jsonList);
  }

  @override
  @override
  Future<void> create(Member m) async {
    final now = nowIso();
    final member = m.copyWith(id: m.id.isEmpty ? generateId() : m.id, createdAt: now, updatedAt: now);
    _cache.add(member);
    await _persist();
    notifyListeners();
  }

  @override
  @override
  Future<void> update(Member m) async {
    final idx = _cache.indexWhere((e) => e.id == m.id);
    if (idx == -1) return;
    final updated = m.copyWith(updatedAt: nowIso());
    _cache[idx] = updated;
    await _persist();
    notifyListeners();
  }

  @override
  @override
  Future<void> softDelete(String id) async {
    final idx = _cache.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _cache[idx] = _cache[idx].copyWith(active: false, updatedAt: nowIso());
    await _persist();
    notifyListeners();
  }

  @override
  @override
  Future<List<Member>> search(String query) async {
    final q = query.toLowerCase();
    return _cache.where((m) => m.active && ('${m.firstName} ${m.lastName}'.toLowerCase().contains(q) || m.phone.contains(q))).toList();
  }
}
