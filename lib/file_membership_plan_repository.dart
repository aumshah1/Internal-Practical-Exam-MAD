import 'dart:async';

import 'package:flutter/foundation.dart';

import 'membership_plan.dart';
import 'membership_plan_repository.dart';
import 'file_storage.dart';
import 'id_generator.dart';

class FileMembershipPlanRepository extends ChangeNotifier implements MembershipPlanRepository {
  final FileStorageService _storage;
  final String _file = 'plans.json';
  final List<MembershipPlan> _cache = [];

  FileMembershipPlanRepository(this._storage);

  Future<void> load() async {
    final list = await _storage.readList(_file);
    _cache.clear();
    for (final e in list) {
      try {
        _cache.add(MembershipPlan.fromJson(e));
      } catch (ignored) {
        if (kDebugMode) print('failed parse plan: $ignored');
      }
    }
    // if no plans present, add a default monthly plan
    if (_cache.isEmpty) {
      final p = MembershipPlan(id: generateId(), name: 'Monthly', price: 2500.0, durationMonths: 1);
      _cache.add(p);
      await _persist();
    }
    notifyListeners();
  }

  @override
  Future<List<MembershipPlan>> getAll() async => List.from(_cache);

  Future<void> _persist() async {
    final jsonList = _cache.map((p) => p.toJson()).toList();
    await _storage.writeList(_file, jsonList);
  }

  @override
  Future<void> create(MembershipPlan p) async {
    final plan = MembershipPlan(id: p.id.isEmpty ? generateId() : p.id, name: p.name, price: p.price, durationMonths: p.durationMonths);
    _cache.add(plan);
    await _persist();
    notifyListeners();
  }

  @override
  Future<void> update(MembershipPlan p) async {
    final idx = _cache.indexWhere((e) => e.id == p.id);
    if (idx == -1) return;
    _cache[idx] = p;
    await _persist();
    notifyListeners();
  }
}
