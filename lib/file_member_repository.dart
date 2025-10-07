import 'dart:async';

import 'package:flutter/foundation.dart';

import 'member.dart';
import 'member_repository.dart';
import 'file_storage.dart';
import 'id_generator.dart';
import 'date_utils.dart';

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
      } catch (ignored) {
        // ignore but keep for debugging
        if (kDebugMode) print('failed to parse member: $ignored');
      }
    }
    notifyListeners();
  }

  List<Member> _visible(bool includeInactive) => includeInactive ? List.from(_cache) : _cache.where((m) => m.active).toList();

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
  Future<void> create(Member m) async {
    final now = nowIso();
    final member = m.copyWith(id: m.id.isEmpty ? generateId() : m.id, createdAt: now, updatedAt: now);
    _cache.add(member);
    await _persist();
    notifyListeners();
  }

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
  Future<void> softDelete(String id) async {
    final idx = _cache.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _cache[idx] = _cache[idx].copyWith(active: false, updatedAt: nowIso());
    await _persist();
    notifyListeners();
  }

  @override
  Future<List<Member>> search(String query) async {
    final q = query.toLowerCase();
    return _cache.where((m) => m.active && ('${m.firstName} ${m.lastName}'.toLowerCase().contains(q) || m.phone.contains(q))).toList();
  }
}
