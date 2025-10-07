import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/member.dart';
import '../../state/app_state.dart';
import '../../utils/id_generator.dart';
import '../../utils/date_utils.dart';

class MemberFormScreen extends StatefulWidget {
  const MemberFormScreen({super.key});

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final repo = appState.memberRepo;

    return Scaffold(
      appBar: AppBar(title: const Text('New Member')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _first,
                decoration: const InputDecoration(labelText: 'First name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _last,
                decoration: const InputDecoration(labelText: 'Last name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final now = nowIso();
                  final member = Member(
                    id: generateId(),
                    firstName: _first.text.trim(),
                    lastName: _last.text.trim(),
                    phone: _phone.text.trim(),
                    email: null,
                    address: null,
                    startDate: now,
                    expiryDate: null,
                    active: true,
                    createdAt: now,
                    updatedAt: now,
                  );
                  await repo.create(member);
                  if (mounted) Navigator.of(context).pop();
                },
                child: const Text('Create'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
