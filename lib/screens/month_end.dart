import 'package:flutter/material.dart';
import 'package:sms_maintained/sms.dart';
import '../database.dart';

class MonthEndScreen extends StatefulWidget {
  const MonthEndScreen({super.key});

  @override
  State<MonthEndScreen> createState() => _MonthEndScreenState();
}

class _MonthEndScreenState extends State<MonthEndScreen> {
  final db = ChamaDatabase();
  bool isProcessing = false;

  Future<void> _runMonthEnd() async {
    setState(() => isProcessing = true);
    final loans = await db.getLoans();
    final members = await db.getMembers();
    final now = DateTime.now();
    final thisMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    // Apply 1% interest to all active loans
    for (var loan in loans) {
      if (loan['balance'] > 0) {
        double interest = loan['balance'] * 0.01;
        double newBalance = loan['balance'] + interest;
        await db.updateLoanBalance(loan['id'], newBalance);
        await db.insertTransaction({
          'member_id': loan['member_id'],
          'type': 'Interest',
          'amount': interest,
          'date': now.toIso8601String(),
          'notes': 'Monthly 1% interest'
        });
      }
    }

    // Send SMS to members who haven’t paid this month
    for (var member in members) {
      final transactions = await db.getMemberLedger(member['id']);
      bool hasPaid = transactions.any((t) =>
          t['type'] == 'Contribution' && t['date'].toString().startsWith(thisMonth));
      if (!hasPaid && member['phone']!= null && member['phone'].toString().isNotEmpty) {
        try {
          SmsSender sender = SmsSender();
          SmsMessage message = SmsMessage(
              member['phone'], 'Hi ${member['name']}, this is a reminder to pay your monthly chama contribution.');
          sender.sendSms(message);
        } catch (e) {
          print('SMS failed for ${member['name']}: $e');
        }
      }
    }

    setState(() => isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Month end completed. Interest applied and SMS sent.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Month End')),
      body: Center(
        child: isProcessing
           ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _runMonthEnd,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                child: const Text('RUN MONTH END', style: TextStyle(fontSize: 18)),
              ),
      ),
    );
  }
}
