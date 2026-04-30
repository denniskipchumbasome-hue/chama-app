import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/dashboard.dart';
import 'screens/pin_auth.dart';
import 'database.dart';

void main() {
  runApp(const ChamaApp());
}

class ChamaApp extends StatefulWidget {
  const ChamaApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _ChamaAppState? state = context.findAncestorStateOfType<_ChamaAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<ChamaApp> createState() => _ChamaAppState();
}

class _ChamaAppState extends State<ChamaApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chama App',
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('sw', '')],
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
    _checkBackupReminder();
  }

  Future<void> _authenticate() async {
    setState(() => _isAuthenticated = true);
  }

  Future<void> _checkBackupReminder() async {
    final db = ChamaDatabase();
    bool isOverdue = await db.isBackupOverdue();
    if (isOverdue && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showBackupDialog());
    }
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(children: [Icon(Icons.warning_amber, color: Colors.orange), SizedBox(width: 8), Text('Backup Reminder')]),
        content: const Text('It has been over 30 days since your last database backup.\n\nPlease backup your chama data now to prevent data loss.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Remind Me Later')),
          ElevatedButton(onPressed: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
          }, child: const Text('Backup Now')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        body: PinAuthScreen(onAuthenticated: () => setState(() => _isAuthenticated = true)),
      );
    }
    return const DashboardScreen();
  }
}
