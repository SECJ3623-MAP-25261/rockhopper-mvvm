import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../auth/home/preferencefilter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color textDark = Color(0xFF212121);

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: primaryBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text('WELCOME BACK',
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.w700, color: textDark)),
              const SizedBox(height: 16),
              TextFormField(controller: _emailController, decoration: const InputDecoration(hintText: 'Email')),
              const SizedBox(height: 12),
              TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(hintText: 'Password')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final success = await vm.login(_emailController.text.trim(), _passwordController.text.trim());
                  if (success) {
                    _showSnackBar("Login successful");
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PreferenceFilteredScreen()));
                  } else {
                    _showSnackBar("Login failed");
                  }
                },
                child: vm.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('LOGIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
