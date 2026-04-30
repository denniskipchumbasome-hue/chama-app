import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../database.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});
  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  final db = ChamaDatabase();
  List<Map<String, dynamic>> logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final data = await db.getActivityLogs();
    setState(() => logs = data);
  }

  Future<void> _exportPDF() async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (c) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text('CHAMA ACTIVITY LOG', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
      pw.Text('Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}'),
      pw.SizedBox(height: 20),
      pw.Table.fromTextArray(headers: ['Date & Time', 'Action', 'Details', 'User'], data: logs.map((l) => [DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(l['timestamp'])), l['action'], l['details']?? '-', l['user']?? 'Treasurer']).toList()),
    ])));
    final file = File('${(await getApplicationDocumentsDirectory()).path}/chama_activity_log.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Log'), actions: [IconButton(icon: const Icon(Icons.download), onPressed: logs.isEmpty? null : _exportPDF)]),
      body: logs.isEmpty
        ? const Center(child: Text('No activity recorded yet'))
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (_, i) {
                final l = logs[i];
                String date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(l['timestamp']));
                return Card(child: ListTile(title: Text(l['action'], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${l['details']}\nBy: ${l['user']}'), trailing: Text(date)));
              },
            ),
    );
  }
}
