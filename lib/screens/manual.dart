import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UserManualScreen extends StatelessWidget {
  const UserManualScreen({super.key});
  Future<void> _exportPDF(BuildContext c) async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(build: (c) => [
      pw.Header(level: 0, child: pw.Text('CHAMA APP - USER MANUAL', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
      pw.Header(level: 1, text: '1. Getting Started'),
      pw.Bullet(text: 'Default PIN is 1234. Change it immediately in Settings.'),
      pw.Header(level: 1, text: '2. Monthly Workflow'),
      pw.Bullet(text: 'Record contributions and loans'),
      pw.Header(level: 1, text: '3. Month End'),
      pw.Bullet(text: 'Run Month End on 1st for interest and SMS'),
    ]));
    final file = File('${(await getApplicationDocumentsDirectory()).path}/chama_manual.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)]);
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('User Manual')), body: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Card(color: Colors.teal.shade50, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('CHAMA APP - QUICK GUIDE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), SizedBox(height: 12), Text('1. Change PIN 1234'), Text('2. Record contributions'), Text('3. Run Month End')]))), const SizedBox(height: 30), ElevatedButton.icon(onPressed: () => _exportPDF(context), icon: const Icon(Icons.picture_as_pdf), label: const Text('Download PDF'))])));
}
