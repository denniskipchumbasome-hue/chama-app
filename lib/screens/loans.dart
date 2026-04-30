import 'package:flutter/material.dart';
import '../database.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  final db = ChamaDatabase();
  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> loans = [];
  int? selectedMemberId;
  final amountController = TextEditingController();
  final repayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    members = await db.getMembers();
    loans = await db.getLoans();
    setState(() {});
  }

  Future<void> _issueLoan() async {
    if (selectedMemberId == null || amountController.text.isEmpty) return;
    double amount = double.parse(amountController.text);

    await db.insertLoan({
      'member_id': selectedMemberId,
      'amount': amount,
      'balance': amount,
      'date_issued': DateTime.now().toIso8601String(),
    });
    amountController.clear();
    selectedMemberId = null;
    _loadData();
  }

  Future<void> _repayLoan(int loanId, double currentBalance) async {
    if (repayController.text.isEmpty) return;
    double repayAmount = double.parse(repayController.text);
    double newBalance = currentBalance - repayAmount;
    if (newBalance < 0) newBalance = 0;

    await db.updateLoanBalance(loanId, newBalance);
    await db.insertTransaction({
      'member_id': loans.firstWhere((l) => l['id'] == loanId)['member_id'],
      'type': 'Loan Repayment',
      'amount': repayAmount,
      'date': DateTime.now().toIso8601String(),
      'notes': 'Loan repayment'
    });
    repayController.clear();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loans')),
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
            TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Loan Amount (KES)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _issueLoan, child: const Text('Issue Loan')),
            const SizedBox(height: 30),
            const Text('Active Loans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: loans.length,
                itemBuilder: (_, i) {
                  final loan = loans[i];
                  final member = members.firstWhere((m) => m['id'] == loan['member_id'], orElse: () => {'name': 'Unknown'});
                  return Card(
                    child: ListTile(
                      title: Text('${member['name']} - KES ${loan['balance']}'),
                      subtitle: Text('Issued: ${loan['date_issued'].toString().substring(0, 10)}'),
                      trailing: SizedBox(
                        width: 120,
                        child: TextField(
                          controller: repayController,
                          decoration: const InputDecoration(hintText: 'Repay KES'),
                          keyboardType: TextInputType.number,
                          onSubmitted: (val) => _repayLoan(loan['id'], loan['balance']),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
