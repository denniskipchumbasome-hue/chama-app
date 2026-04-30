import 'package:flutter/material.dart';
import '../database.dart';

class FinesWelfareScreen extends StatefulWidget {
  const FinesWelfareScreen({super.key});

  @override
  State<FinesWelfareScreen> createState() => _FinesWelfareScreenState();
}

class _FinesWelfareScreenState extends State<FinesWelfareScreen> {
  final db = ChamaDatabase();
  List<Map<String, dynamic>> members = [];
  int? selectedMemberId;
  final amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final data = await db.getMembers();
    setState(() => members = data);
  }

  Future<void> _recordFine() async {
    if (selectedMemberId == null || amountController.text.isEmpty) return;
    double amount = double.parse(amountController.text);

    await db.insertTransaction({
      'member_id': selectedMemberId,
      'type': 'Fine',
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
      'notes': 'Late contribution fine'
    });
    amountController.clear();
    selectedMemberId = null;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fine recorded')));
  }

  Future<void> _disburseWelfare() async {
    if (selectedMemberId == null || amountController.text.isEmpty) return;
    double amount = double.parse(amountController.text);

    await db.insertTransaction({
      'member_id': selectedMemberId,
      'type': 'Welfare Disbursement',
      'amount': -amount,
      'date': DateTime.now().toIso8601String(),
      'notes': 'Welfare support'
    });

    var member = members.firstWhere((m) => m['id'] == selectedMemberId);
    double newBalance = (member['welfare_balance'] as double) - amount;
    await db.updateMember({'id': selectedMemberId, 'welfare_balance': newBalance});

    amountController.clear();
    selectedMemberId = null;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welfare disbursed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fines & Welfare')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: selectedMemberId,
              decoration: const InputDecoration(labelText: 'Select Member'),
              items: members.map((m) => DropdownMenuItem(value: m['id'], child: Text(m['name']))).toList(),
              onChanged: (val) => setState(() => selectedMemberId = val),
            ),
            const SizedBox(height: 12),
            TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount (KES)'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _recordFine, child: const Text('Record Fine'))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: _disburseWelfare, child: const Text('Disburse Welfare'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
