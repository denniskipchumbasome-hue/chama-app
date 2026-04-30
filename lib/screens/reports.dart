import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../database.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final db = ChamaDatabase();
  List<Map<String, dynamic>> members = [];
  int? selectedMemberId;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final data = await db.getMembers();
    setState(() => members = data);
  }

  Future<void> _exportMemberStatement() async {
    if (selectedMemberId == null) return;
    final member = members.firstWhere((m) => m['id'] == selectedMemberId);
    final ledger = await db.getMemberLedger(selectedMemberId!);

    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('CHAMA MEMBER STATEMENT', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Name: ${member['name']}'),
          pw.Text('Phone: ${member['phone']}'),
          pw.Text('Savings Balance: KES ${member['savings_balance']}'),
          pw.Text('Welfare Balance: KES ${member['welfare_balance']}'),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Date', 'Type', 'Amount', 'M-Pesa Code', 'Notes'],
            data: ledger.map((t) => [
              t['date'].toString().substring(0, 10),
              t['type'],
