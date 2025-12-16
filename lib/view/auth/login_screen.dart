import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pinjamtech_app/view_model/auth_viewmodel.dart';
import 'forgot_password.dart';
import '../home/preferencefilter.dart';

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
  static const Color textLight = Color(0xFF757575);

Future<void> _handleLogin() async {
  final authVM = context.read<AuthViewModel>();

  await authVM.login(
    email: _emailController.text,
    password: _passwordController.text,
  );

  if (authVM.errorMessage != null) {
    _showSnackBar(authVM.errorMessage!);
    return;
  }

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => PreferenceFilteredScreen()),
  );
}


  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'WELCOME BACK',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              _label("Email"),
              _input(_emailController, "Enter your email"),

              const SizedBox(height: 20),

  
              _label("Password"),
              _input(_passwordController, "Enter your password",
                  obscure: true),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ForgotPassword()),
                    );
                  },
                  child: Text("Forgot password?",
                      style: GoogleFonts.poppins(color: primaryBlue)),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authVM.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                  ),
                  child: authVM.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("DONE"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500, color: textDark),
      );

  Widget _input(TextEditingController c, String hint,
      {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: textLight),
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}