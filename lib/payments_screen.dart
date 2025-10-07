import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'payment.dart';
import 'member.dart';
import 'date_utils.dart';
import 'id_generator.dart';
import 'edit_payment_screen.dart';
import 'ui_utils.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  bool _showOrphans = false; // payments whose member no longer exists

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final repo = appState.paymentRepo;

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: AnimatedBuilder(
        animation: repo,
        builder: (context, _) {
          // Fetch payments and members together so we can show member names
          return FutureBuilder<List<dynamic>>(
            future: Future.wait([repo.getAll(), Provider.of<AppState>(context, listen: false).memberRepo.getAll()]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final payments = (snapshot.data != null && snapshot.data!.isNotEmpty) ? (snapshot.data![0] as List<Payment>) : <Payment>[];
              final members = (snapshot.data != null && snapshot.data!.length > 1) ? (snapshot.data![1] as List) : <dynamic>[];
              final Map<String, String> nameById = {};
              for (final m in members) {
                try {
                  nameById[m.id as String] = '${m.firstName} ${m.lastName}';
                } catch (_) {}
              }

              if (payments.isEmpty) return const Center(child: Text('No payments yet'));

              final visible = _showOrphans ? payments : payments.where((p) => nameById.containsKey(p.memberId)).toList();
              final hiddenCount = payments.length - visible.length;

              return Column(
                children: [
                  if (hiddenCount > 0 && !_showOrphans)
                    Container(
                      color: Colors.orange.shade50,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$hiddenCount payment(s) hidden because member was removed'),
                          TextButton(onPressed: () => setState(() => _showOrphans = true), child: const Text('Show all'))
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: visible.length,
                      itemBuilder: (context, i) {
                        final p = visible[i];
                        final memberName = nameById[p.memberId] ?? p.memberId;
                        return ListTile(
                          title: Text('${formatCurrency(p.amount)} • ${p.method.toUpperCase()}'),
                          subtitle: Text('${formatShortDate(p.paidAt)} • $memberName'),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditPaymentScreen(payment: p))),
                        );
                      },
                    ),
                  )
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddPaymentScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddPaymentScreen extends StatefulWidget {
  final String? initialMemberId;
  const AddPaymentScreen({super.key, this.initialMemberId});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _memberId = '';
  final _amount = TextEditingController();
  String _method = 'cash';

  @override
  void initState() {
    super.initState();
    if (widget.initialMemberId != null) {
      _memberId = widget.initialMemberId!;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final members = appState.memberRepo;
    final initial = widget.initialMemberId;
    return Scaffold(
      appBar: AppBar(title: const Text('New Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FutureBuilder<List<Member>>(
                future: members.getAll(),
                builder: (context, snap) {
                  final list = snap.data ?? [];
                  final defaultValue = initial ?? (_memberId.isEmpty && list.isNotEmpty ? list.first.id : (_memberId.isEmpty ? null : _memberId));
                  return DropdownButtonFormField<String>(
                    value: defaultValue,
                    items: list.map((m) => DropdownMenuItem(value: m.id, child: Text('${m.firstName} ${m.lastName}'))).toList(),
                    onChanged: (v) => setState(() => _memberId = v ?? ''),
                    decoration: const InputDecoration(labelText: 'Member'),
                  );
                },
              ),
              TextFormField(
                controller: _amount,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter amount' : null,
              ),
              DropdownButtonFormField<String>(
                value: _method,
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'card', child: Text('Card')),
                ],
                onChanged: (v) => setState(() => _method = v ?? 'cash'),
                decoration: const InputDecoration(labelText: 'Method'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  // Determine effective memberId: prefer explicit selection, then initialMemberId, then first member in list.
                  final membersList = await members.getAll();
                  final effectiveMemberId = _memberId.isNotEmpty
                      ? _memberId
                      : (widget.initialMemberId ?? (membersList.isNotEmpty ? membersList.first.id : ''));
                  if (effectiveMemberId.isEmpty) {
                    // no member available/selected
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a member or create one first')));
                    return;
                  }
                  final now = nowIso();
                  final p = Payment(id: generateId(), memberId: effectiveMemberId, amount: double.parse(_amount.text), method: _method, paidAt: now);
                  final navigator = Navigator.of(context);
                  await appState.paymentRepo.create(p);
                  if (!mounted) return;
                  navigator.pop();
                },
                child: const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
