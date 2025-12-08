// lib/ui/forgot_password_screen.dart
import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _sendResetEmail,
              child: _loading ? const CircularProgressIndicator() : const Text('Send reset email'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!, style: const TextStyle(color: Colors.green)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _sendResetEmail() async {
    setState(() { _loading = true; _message = null; });
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() { _loading = false; _message = 'Email is required'; });
      return;
    }

    try {
      // IMPORTANT: pick a redirectTo URL that your Supabase dashboard allows (whitelist).
      // Option A: a web page that forwards to your app
      // Option B: a mobile deep link like 'io.supabase.flutter://signin-callback/reset-password'
      final redirectTo = 'io.supabase.flutter://signin-callback/reset-password';

      await _auth.sendPasswordResetEmail(email, redirectTo: redirectTo);

      setState(() {
        _message = 'Reset email sent. Check your inbox.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error sending reset email: ${e.toString()}';
      });
    } finally {
      setState(() { _loading = false; });
    }
  }
}
