import 'package:flutter/material.dart';
import '../database.dart';

class YearEndScreen extends StatefulWidget {
  const YearEndScreen({super.key});

  @override
  State<YearEndScreen> createState() => _YearEndScreenState();
}

class _YearEndScreenState extends State<YearEndScreen> {
  final db = ChamaDatabase();
  final surplusController = TextEditingController();
  Map<String, double> calculation = {};

  void _calculateDistribution() {
    double surplus = double.parse(surplusController.text);
    double reserve = surplus * 0.10;
    double interest = surplus * 0.05;
    double project = surplus * 0.20;
    double dividend = surplus * 0.80;
    setState(() {
      calculation = {
        'Reserve': reserve,
        'Interest on Savings': interest,
        'Project': project,
        'Dividend': dividend,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Year End Calculation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: surplusController,
              decoration: const InputDecoration(labelText: 'Net Surplus (KES)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _calculateDistribution, child: const Text('Calculate 10/20/80 Distribution')),
            const SizedBox(height: 30),
            if (calculation.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: calculation.entries
                       .map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text('${e.key}: KES ${e.value.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                            ))
                       .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
