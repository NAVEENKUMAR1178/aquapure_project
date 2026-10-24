import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final name = TextEditingController(), email = TextEditingController(),
      pass = TextEditingController(), phone = TextEditingController();
  bool register = false, busy = false;
  String role = 'Customer';

  Future<void> submit() async {
    setState(() => busy = true);
    final s = context.read<AppState>();
    try {
      register
          ? await s.register(name.text.trim(), email.text.trim(), pass.text,
              phone.text.trim(), role)
          : await s.login(email.text.trim(), pass.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.all(24), children: [
            const SizedBox(height: 40),
            const Icon(Icons.water_drop, size: 72, color: Colors.blue),
            Text('AquaPure',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            if (register) ...[
              TextField(controller: name,
                  decoration: const InputDecoration(labelText: 'Full name')),
              TextField(controller: phone, keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone')),
            ],
            TextField(controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: pass, obscureText: true,
                decoration: const InputDecoration(labelText: 'Password')),
            if (register)
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Customer', label: Text('Customer')),
                  ButtonSegment(value: 'Dealer', label: Text('Dealer')),
                ],
                selected: {role},
                onSelectionChanged: (v) => setState(() => role = v.first),
              ),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: busy ? null : submit,
                child: Text(register ? 'Create account' : 'Login')),
            TextButton(
                onPressed: () => setState(() => register = !register),
                child: Text(register
                    ? 'Have an account? Login'
                    : 'New here? Register')),
          ]),
        ),
      );
}
