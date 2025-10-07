import 'package:flutter/material.dart';
import 'members_list_screen.dart';
import 'payments_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gym Manager')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.people),
              label: const Text('Members'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MembersListScreen())),
            ),
            const SizedBox(height: 12),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentsScreen())),
                child: const Text('Payments'),
              ),
          ],
        ),
      ),
    );
  }
}
