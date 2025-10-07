import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'payment.dart';
import 'app_state.dart';

class EditPaymentScreen extends StatefulWidget {
  final Payment payment;
  const EditPaymentScreen({super.key, required this.payment});

  @override
  State<EditPaymentScreen> createState() => _EditPaymentScreenState();
}

class _EditPaymentScreenState extends State<EditPaymentScreen> {
  late TextEditingController _amount;
  String _method = 'cash';
  late TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: widget.payment.amount.toString());
    _method = widget.payment.method;
    _note = TextEditingController(text: widget.payment.note);
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Payment'), actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete payment'), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete'))]));
            if (ok == true) {
              await appState.paymentRepo.delete(widget.payment.id);
              if (context.mounted) Navigator.of(context).pop();
            }
          },
        )
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Text('Member: ${widget.payment.memberId}'),
          TextFormField(controller: _amount, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
          DropdownButtonFormField<String>(value: _method, items: const [DropdownMenuItem(value: 'cash', child: Text('Cash')), DropdownMenuItem(value: 'card', child: Text('Card'))], onChanged: (v) => setState(() => _method = v ?? 'cash'), decoration: const InputDecoration(labelText: 'Method')),
          TextFormField(controller: _note, decoration: const InputDecoration(labelText: 'Note')),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final amt = double.tryParse(_amount.text) ?? widget.payment.amount;
              final updated = Payment(id: widget.payment.id, memberId: widget.payment.memberId, amount: amt, method: _method, paidAt: widget.payment.paidAt, status: widget.payment.status, note: _note.text);
              await appState.paymentRepo.update(updated);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Save'),
          )
        ]),
      ),
    );
  }
}
