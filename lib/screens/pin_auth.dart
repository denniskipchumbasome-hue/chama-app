import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../database.dart';

class PinAuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const PinAuthScreen({super.key, required this.onAuthenticated});

  @override
  State<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends State<PinAuthScreen> {
  final pinController = TextEditingController();
  final db = ChamaDatabase();
  final auth = LocalAuthentication();
  String error = '';
  bool showForgotOption = false;

  Future<void> _verifyPin() async {
    final settings = await db.getSettings();
    String correctPin = settings['treasurer_pin'] as String;

    if (pinController.text == correctPin) {
      await db.logActivity('Settings Access', details: 'Successful PIN login');
      widget.onAuthenticated();
    } else {
      await db.logActivity('Settings Access', details: 'Failed PIN attempt');
      setState(() {
        error = 'Incorrect PIN. Try again.';
        showForgotOption = true;
      });
      pinController.clear();
    }
  }

  Future<void> _resetPinWithBiometric() async {
    bool canCheck = await auth.canCheckBiometrics;
    if (!canCheck) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric not available on this device'))
      );
      return;
    }

    bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Verify your identity to reset Treasurer PIN',
      options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
    );

    if (didAuthenticate) {
      await db.updateSettings({'treasurer_pin': '1234'});
      await db.logActivity('PIN Reset', details: 'PIN reset to 1234 via biometric');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN reset to 1234. Please change it immediately in Settings.'))
      );
      widget.onAuthenticated();
    } else {
      await db.logActivity('PIN Reset', details: 'Failed biometric attempt');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication failed'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              const Text('Treasurer Access', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: pinController,
                decoration: InputDecoration(
                  labelText: 'Enter 4-digit PIN',
                  border: const OutlineInputBorder(),
                  errorText: error.isEmpty? null : error,
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _verifyPin, child: const Text('Login')),
              if (showForgotOption)...[
                const SizedBox(height: 10),
                TextButton(onPressed: _resetPinWithBiometric, child: const Text('Forgot PIN? Reset with Fingerprint')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
