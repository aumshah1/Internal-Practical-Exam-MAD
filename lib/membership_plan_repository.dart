import 'membership_plan.dart';

abstract class MembershipPlanRepository {
  Future<List<MembershipPlan>> getAll();
  Future<void> create(MembershipPlan p);
  Future<void> update(MembershipPlan p);
}
