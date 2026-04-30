import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database.dart';

class MonthEndScreen extends StatefulWidget {
  const MonthEndScreen({super.key});
  @override
  State<MonthEndScreen> createState() => _MonthEndScreenState();
}

class _MonthEndScreenState extends State<MonthEndScreen> {
  final db = ChamaDatabase();
  bool isProcessing = false;
  String reminderText = '';

  Future<void> _runMonthEnd() async {
    setState(() => isProcessing = true);
    final loans = await db.getLoans();
    final members = await db.getMembers();
    final now = DateTime.now();
    final thisMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    // Apply 1% interest
    for (var loan in loans) {
      if (loan['balance'] > 0) {
        double interest = loan['balance'] * 0.01;
        await db.updateLoanBalance(loan['id'], loan['balance'] + interest);
        await db.insertTransaction({'member_id': loan['member_id'], 'type': 'Interest', 'amount': interest, 'date': now.toIso8601String(), 'notes': 'Monthly 1% interest'});
      }
    }

    // Generate reminder message for non-paying members
    StringBuffer buffer = StringBuffer();
    buffer.writeln('CHAMA MONTHLY REMINDER - ${DateFormat('MMMM yyyy').format(now)}');
    buffer.writeln('---------------------------');
    
    for (var member in members) {
      final transactions = await db.getMemberLedger(member['id']);
      bool hasPaid = transactions.any((t) => t['type'] == 'Contribution' && t['date'].toString().startsWith(thisMonth));
      if (!hasPaid && member['phone'] != null && member['phone'].toString().isNotEmpty) {
        buffer.writeln('Hi ${member['name']}, reminder to pay your monthly chama contribution of KES ${await _getMonthlyContribution()}.');
      }
    }
    
    reminderText = buffer.toString();
    setState(() => isProcessing = false);
    await db.logActivity('Month End Run', details: 'Interest applied and reminders generated');
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Month end completed. Interest applied.')));
  }

  Future<double> _getMonthlyContribution() async {
    final s = await db.getSettings();
    return s['monthly_contribution'] ?? 500.0;
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: reminderText));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder text copied. Paste it to WhatsApp.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Month End')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isProcessing)
              ElevatedButton(
                onPressed: _runMonthEnd, 
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)), 
                child: const Text('RUN MONTH END', style: TextStyle(fontSize: 18))
              ),
            if (isProcessing) const Center(child: CircularProgressIndicator()),
            if (reminderText.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Copy this and send to members via WhatsApp:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                child: SelectableText(reminderText, style: const TextStyle(fontFamily: 'monospace')),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(onPressed: _copyToClipboard, icon: const Icon(Icons.copy), label: const Text('COPY TO CLIPBOARD')),
            ]
          ],
        ),
      ),
    );
  }
}
