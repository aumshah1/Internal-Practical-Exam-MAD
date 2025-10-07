import 'payment.dart';

abstract class PaymentRepository {
  Future<List<Payment>> getAll();
  Future<List<Payment>> getByMember(String memberId);
  Future<void> create(Payment p);
  Future<void> update(Payment p);
  Future<void> delete(String id);
}
