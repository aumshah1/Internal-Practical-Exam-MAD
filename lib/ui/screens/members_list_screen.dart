import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../models/member.dart';
import '../widgets/member_tile.dart';
import 'member_form_screen.dart';

class MembersListScreen extends StatelessWidget {
  const MembersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final repo = appState.memberRepo;

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: AnimatedBuilder(
        animation: repo,
        builder: (context, _) {
          return FutureBuilder<List<Member>>(
            future: repo.getAll(),
            builder: (context, snapshot) {
              final list = snapshot.data ?? [];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (list.isEmpty) {
                return const Center(child: Text('No members yet. Tap + to add.'));
              }
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) => MemberTile(member: list[i]),
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
