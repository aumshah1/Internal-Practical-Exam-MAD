import 'package:flutter/material.dart';
import '../../models/member.dart';

class MemberTile extends StatelessWidget {
  final Member member;
  const MemberTile({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${member.firstName} ${member.lastName}'),
      subtitle: Text(member.phone),
      trailing: member.active ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.remove_circle, color: Colors.grey),
    );
  }
}
