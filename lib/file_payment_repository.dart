import 'dart:async';

import 'package:flutter/foundation.dart';

import 'payment.dart';
import 'file_storage.dart';
import 'id_generator.dart';
import 'payment_repository.dart';

class FilePaymentRepository extends ChangeNotifier implements PaymentRepository {
  final FileStorageService _storage;
  final String _file = 'payments.json';
  final List<Payment> _cache = [];

  FilePaymentRepository(this._storage);

  Future<void> load() async {
    final list = await _storage.readList(_file);
    _cache.clear();
    for (final e in list) {
      try {
        _cache.add(Payment.fromJson(e));
      } catch (ignored) {
        if (kDebugMode) print('failed to parse payment: $ignored');
      }
    }
    notifyListeners();
  }

  @override
  Future<List<Payment>> getAll() async => List.from(_cache);

  @override
  Future<List<Payment>> getByMember(String memberId) async => _cache.where((p) => p.memberId == memberId).toList();

  Future<void> _persist() async {
    final jsonList = _cache.map((p) => p.toJson()).toList();
    await _storage.writeList(_file, jsonList);
  }

  @override
  Future<void> create(Payment p) async {
    final pay = Payment(id: p.id.isEmpty ? generateId() : p.id, memberId: p.memberId, amount: p.amount, method: p.method, paidAt: p.paidAt, status: p.status, note: p.note);
    _cache.add(pay);
    await _persist();
    notifyListeners();
  }

  @override
  Future<void> update(Payment p) async {
    final idx = _cache.indexWhere((e) => e.id == p.id);
    if (idx == -1) return;
    _cache[idx] = p;
    await _persist();
    notifyListeners();
  }

  @override
  Future<void> delete(String id) async {
    _cache.removeWhere((e) => e.id == id);
    await _persist();
    notifyListeners();
  }
}
