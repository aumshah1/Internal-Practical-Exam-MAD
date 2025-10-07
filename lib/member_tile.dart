import 'package:flutter/material.dart';
import 'member.dart';
import 'member_detail_screen.dart';
import 'ui_utils.dart';

class MemberTile extends StatelessWidget {
  final Member member;
  final String? planName;
  final String? nextDue;
  final String? status;
  const MemberTile({super.key, required this.member, this.planName, this.nextDue, this.status});

  @override
  Widget build(BuildContext context) {
    final subtitle = <Widget>[Text(member.phone)];
  if (planName != null && planName!.isNotEmpty) subtitle.add(Text('Plan: $planName'));
  if (nextDue != null && nextDue!.isNotEmpty) subtitle.add(Text('Due: ${formatShortDate(nextDue)}'));

    Widget? badge;
    if (status != null) {
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
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Text(status!, style: const TextStyle(color: Colors.white, fontSize: 12)),
      );
    }

    final initials = (member.firstName.isNotEmpty ? member.firstName[0] : '') + (member.lastName.isNotEmpty ? member.lastName[0] : '');
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.deepOrange.shade100, child: Text(initials.toUpperCase())),
      title: Text('${member.firstName} ${member.lastName}'),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: subtitle.map((w) => DefaultTextStyle(style: const TextStyle(fontSize: 12), child: w)).toList()),
      trailing: badge ?? (member.active ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.remove_circle, color: Colors.grey)),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MemberDetailScreen(member: member))),
    );
  }
}
