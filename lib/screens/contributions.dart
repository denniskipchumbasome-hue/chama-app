import 'package:flutter/material.dart';
import '../database.dart';

class ContributionsScreen extends StatefulWidget {
  const ContributionsScreen({super.key});

  @override
  State<ContributionsScreen> createState() => _ContributionsScreenState();
}

class _ContributionsScreenState extends State<ContributionsScreen> {
  final db = ChamaDatabase();
  List<Map<String, dynamic>> members = [];
  int? selectedMemberId;
  final amountController = TextEditingController();
  final mpesaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final data = await db.getMembers();
    setState(() => members = data);
  }

  Future<void> _recordContribution() async {
    if (selectedMemberId == null || amountController.text.isEmpty) return;
    double amount = double.parse(amountController.text);

    await db.insertTransaction({
      'member_id': selectedMemberId,
      'type': 'Contribution',
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
      'mpesa_code': mpesaController.text,
      'notes': 'Monthly contribution'
    });

    var member = members.firstWhere((m) => m['id'] == selectedMemberId);
    double newBalance = (member['savings_balance'] as double) + amount;
    await db.updateMember({'id': selectedMemberId, 'savings_balance': newBalance});

    amountController.clear();
    mpesaController.clear();
    selectedMemberId = null;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contribution recorded')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contributions')),
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
            const SizedBox(height: 12),
            TextField(controller: mpesaController, decoration: const InputDecoration(labelText: 'M-Pesa Code')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _recordContribution, child: const Text('Record Contribution')),
          ],
        ),
      ),
    );
  }
}
