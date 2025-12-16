
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinjamtech_app/view_model/auth_viewmodel.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool agree = false;

  static const primaryBlue = Color(0xFF2196F3);

  Future<void> _handleSignup() async {
    final authVM = context.read<AuthViewModel>();

    if (!agree) {
      _show("Agree to terms first");
      return;
    }

    try {
      await authVM.signUp(
        email: _email.text,
        password: _password.text,
        fullName: _name.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (_) {
      _show(authVM.errorMessage ?? "Signup failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("SIGN UP")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _field(_name, "Full Name"),
            _field(_email, "Email"),
            _field(_password, "Password", obscure: true),

            CheckboxListTile(
              value: agree,
              onChanged: (v) => setState(() => agree = v ?? false),
              title: const Text("Agree to terms"),
            ),

            ElevatedButton(
              onPressed: authVM.isLoading ? null : _handleSignup,
              child: authVM.isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      decoration: InputDecoration(labelText: label),
    );
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}