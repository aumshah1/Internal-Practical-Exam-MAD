import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'member.dart';
import 'app_state.dart';
import 'payment.dart';
import 'attendance.dart';
import 'date_utils.dart';
import 'id_generator.dart';
import 'payments_screen.dart';
import 'member_form_screen.dart';
import 'edit_payment_screen.dart';

class MemberDetailScreen extends StatelessWidget {
  final Member member;
  const MemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${member.firstName} ${member.lastName}'),
          bottom: const TabBar(tabs: [Tab(text: 'Profile'), Tab(text: 'Payments'), Tab(text: 'Attendance')]),
        ),
        body: TabBarView(children: [ProfileTab(member: member), PaymentsTab(member: member), AttendanceTab(member: member)]),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  final Member member;
  const ProfileTab({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text('Name: ${member.firstName} ${member.lastName}'),
          const SizedBox(height: 8),
          Text('Phone: ${member.phone}'),
          const SizedBox(height: 8),
          Text('Start: ${member.startDate}'),
          const SizedBox(height: 8),
          Text('Expiry: ${member.expiryDate ?? 'N/A'}'),
          const SizedBox(height: 8),
          Text('Plan: ${member.planId ?? 'No plan'}'),
          const SizedBox(height: 8),
          Text('Next due: ${member.nextDueDate ?? 'N/A'}'),
          const SizedBox(height: 12),
          FutureBuilder<List<Payment>>(
            future: appState.paymentRepo.getByMember(member.id),
            builder: (context, snap) {
              final payments = snap.data ?? [];
              String status = 'No Plan';
              if (member.nextDueDate != null) {
                try {
                  final due = DateTime.parse(member.nextDueDate!);
                  final last = payments.isNotEmpty ? DateTime.parse(payments.last.paidAt) : null;
                  final now = DateTime.now();
                  if (last != null && !last.isBefore(due)) {
                    status = 'Paid';
                  } else if (now.isAfter(due)) {
                    status = 'Due';
                  } else {
                    status = 'Upcoming';
                  }
                } catch (_) {
                  status = 'Unknown';
                }
              }
              Color bg;
              switch (status) {
                case 'Paid':
                  bg = Colors.green;
                  break;
                case 'Due':
                  bg = Colors.red;
                  break;
                case 'Upcoming':
                  bg = Colors.orange;
                  break;
                default:
                  bg = Colors.grey;
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: const TextStyle(color: Colors.white)),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // open edit form
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => MemberFormScreen(existing: member)));
                  },
                  child: const Text('Edit Member'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete member'),
                  content: const Text('Are you sure you want to delete this member? This will mark them inactive.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                  ],
                ),
              );
              if (confirm == true) {
                await appState.memberRepo.softDelete(member.id);
                if (context.mounted) {
                  Navigator.of(context).pop(); // close detail screen
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member deleted')));
                }
              }
                  },
                  child: const Text('Delete Member'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PaymentsTab extends StatelessWidget {
  final Member member;
  const PaymentsTab({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final payments = appState.paymentRepo;
    return Column(
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: payments,
            builder: (context, _) {
              return FutureBuilder<List<Payment>>(
                future: payments.getByMember(member.id),
                builder: (context, snap) {
                  final list = snap.data ?? [];
                  if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (list.isEmpty) return const Center(child: Text('No payments'));
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final p = list[i];
                      return ListTile(title: Text('₹${p.amount}'), subtitle: Text(p.paidAt), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditPaymentScreen(payment: p))));
                    },
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddPaymentScreen(initialMemberId: member.id))),
            child: const Text('Add Payment'),
          ),
        )
      ],
    );
  }
}

class AttendanceTab extends StatelessWidget {
  final Member member;
  const AttendanceTab({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final repo = appState.attendanceRepo;
    return Column(
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: repo,
            builder: (context, _) {
              return FutureBuilder<List<AttendanceRecord>>(
                future: repo.getByMember(member.id),
                builder: (context, snap) {
                  final list = snap.data ?? [];
                  if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (list.isEmpty) return const Center(child: Text('No attendance records'));
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final r = list[i];
                      return ListTile(title: Text(r.at), subtitle: Text(r.note));
                    },
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              final now = nowIso();
              final record = AttendanceRecord(id: generateId(), memberId: member.id, at: now);
              await appState.attendanceRepo.create(record);
            },
            child: const Text('Mark Present'),
          ),
        )
      ],
    );
  }
}
