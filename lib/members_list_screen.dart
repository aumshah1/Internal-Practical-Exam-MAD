import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'member.dart';
import 'member_tile.dart';
import 'member_form_screen.dart';

class MembersListScreen extends StatelessWidget {
  const MembersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
  final appState = Provider.of<AppState>(context);
  final repo = appState.memberRepo;
  final planRepo = appState.planRepo;

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: AnimatedBuilder(
        animation: repo,
        builder: (context, _) {
          return FutureBuilder<List<dynamic>>(
            future: Future.wait([repo.getAll(), planRepo.getAll(), Provider.of<AppState>(context, listen: false).paymentRepo.getAll()]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final list = (snapshot.data != null && snapshot.data!.isNotEmpty) ? (snapshot.data![0] as List<Member>) : <Member>[];
              final plans = (snapshot.data != null && snapshot.data!.length > 1) ? (snapshot.data![1] as List) : <dynamic>[];
              final payments = (snapshot.data != null && snapshot.data!.length > 2) ? (snapshot.data![2] as List) : <dynamic>[];
              final Map<String, String> planNameById = {};
              for (final p in plans) {
                try {
                  planNameById[p.id as String] = p.name as String;
                } catch (_) {}
              }
              if (list.isEmpty) {
                return const Center(child: Text('No members yet. Tap + to add.'));
              }
              // build latest payment map
              final Map<String, DateTime> latestByMember = {};
              for (final p in payments) {
                try {
                  final mp = p as dynamic;
                  final mid = mp.memberId as String;
                  final paidAt = DateTime.parse(mp.paidAt as String);
                  if (!latestByMember.containsKey(mid) || latestByMember[mid]!.isBefore(paidAt)) {
                    latestByMember[mid] = paidAt;
                  }
                } catch (_) {}
              }

              final now = DateTime.now();
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final m = list[i];
                  final planName = m.planId != null ? (planNameById[m.planId] ?? 'Plan: ${m.planId}') : 'No plan';
                  final dueStr = m.nextDueDate;
                  String status = 'No Plan';
                  if (dueStr != null && dueStr.isNotEmpty) {
                    try {
                      final due = DateTime.parse(dueStr);
                      final last = latestByMember[m.id];
                      if (last != null && !last.isBefore(due)) {
                        status = 'Paid';
                      } else if (now.isAfter(due)) {
                        status = 'Due';
                      } else {
                        final days = due.difference(now).inDays;
                        status = days <= 7 ? 'Upcoming' : 'Upcoming';
                      }
                    } catch (_) {
                      status = 'Unknown';
                    }
                  }
                  return MemberTile(member: m, planName: planName, nextDue: dueStr ?? '', status: status);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MemberFormScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
