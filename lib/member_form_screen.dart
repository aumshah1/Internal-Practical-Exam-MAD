import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'member.dart';
import 'app_state.dart';
import 'id_generator.dart';
import 'date_utils.dart';

class MemberFormScreen extends StatefulWidget {
  final Member? existing;
  const MemberFormScreen({super.key, this.existing});

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();
  String? _selectedPlanId;

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
    final planRepo = appState.planRepo;
    final existing = widget.existing;

    // Prefill when editing
    if (existing != null) {
      _first.text = existing.firstName;
      _last.text = existing.lastName;
      _phone.text = existing.phone;
      _selectedPlanId = existing.planId;
    }

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
              const SizedBox(height: 12),
              FutureBuilder<List<dynamic>>(
                future: planRepo.getAll(),
                builder: (context, snap) {
                  final plans = snap.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedPlanId ?? (plans.isNotEmpty ? plans.first.id as String : null),
                    items: plans.map<DropdownMenuItem<String>>((p) => DropdownMenuItem<String>(value: p.id as String, child: Text('${p.name} - ₹${(p.price as double).toStringAsFixed(0)}'))).toList(),
                    onChanged: (v) => setState(() => _selectedPlanId = v),
                    decoration: const InputDecoration(labelText: 'Membership Plan'),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final now = nowIso();
                  final start = now;
                  String? nextDue;
                  if (_selectedPlanId != null) {
                    final plans = await planRepo.getAll();
                    final p = plans.firstWhere((e) => e.id == _selectedPlanId, orElse: () => plans.first);
                    final durationMonths = p.durationMonths as int? ?? p.durationMonths;
                    final dt = DateTime.parse(start).add(Duration(days: 30 * durationMonths));
                    nextDue = dt.toIso8601String();
                  }

                  if (existing == null) {
                    final member = Member(
                      id: generateId(),
                      firstName: _first.text.trim(),
                      lastName: _last.text.trim(),
                      phone: _phone.text.trim(),
                      email: null,
                      address: null,
                      planId: _selectedPlanId,
                      startDate: start,
                      expiryDate: null,
                      nextDueDate: nextDue,
                      active: true,
                      createdAt: now,
                      updatedAt: now,
                    );
                    await repo.create(member);
                  } else {
                    final updated = existing.copyWith(
                      firstName: _first.text.trim(),
                      lastName: _last.text.trim(),
                      phone: _phone.text.trim(),
                      planId: _selectedPlanId,
                      nextDueDate: nextDue,
                      updatedAt: now,
                    );
                    await repo.update(updated);
                  }
                  if (mounted) Navigator.of(context).pop();
                },
                child: Text(existing == null ? 'Create' : 'Save'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
