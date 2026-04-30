import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../database.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final db = ChamaDatabase();
  final contributionController = TextEditingController();
  final pinController = TextEditingController();
  bool unlocked = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = await db.getSettings();
    contributionController.text = s['monthly_contribution'].toString();
  }

  Future<void> _unlock() async {
    final s = await db.getSettings();
    if (pinController.text == s['treasurer_pin']) {
      setState(() => unlocked = true);
      await db.logActivity('Settings Access', details: 'Successful PIN login');
    } else {
      await db.logActivity('Settings Access', details: 'Failed PIN attempt');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect PIN')));
    }
  }

  Future<void> _save() async {
    if (!unlocked) return;
    await db.updateSettings({'monthly_contribution': double.parse(contributionController.text)});
    await db.logActivity('Settings Updated', details: 'Monthly contribution changed');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('Language / Lugha', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: Localizations.localeOf(context).languageCode,
            decoration: const InputDecoration(labelText: 'Select Language', border: OutlineInputBorder()),
            items: const [DropdownMenuItem(value: 'en', child: Text('English')), DropdownMenuItem(value: 'sw', child: Text('Kiswahili'))],
            onChanged: (v) { if (v!= null) ChamaApp.setLocale(context, Locale(v)); },
          ),
          const SizedBox(height: 20),
          if (!unlocked)...[
            TextField(controller: pinController, decoration: const InputDecoration(labelText: 'Enter Treasurer PIN', border: OutlineInputBorder()), obscureText: true, keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _unlock, child: const Text('Unlock Settings')),
          ] else...[
            TextField(controller: contributionController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.amountKES, border: const OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: Text(AppLocalizations.of(context)!.save)),
          ]
        ]),
      ),
    );
  }
}
