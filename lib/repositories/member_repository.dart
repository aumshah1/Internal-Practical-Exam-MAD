import '../models/member.dart';

abstract class MemberRepository {
  Future<List<Member>> getAll({bool includeInactive = false});
  Future<Member?> getById(String id);
  Future<void> create(Member m);
  Future<void> update(Member m);
  Future<void> softDelete(String id);
  Future<List<Member>> search(String query);
}
