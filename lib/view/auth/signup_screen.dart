// lib/view/auth/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import '../../viewmodel/auth_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreeToTerms = false;

  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: primaryBlue,
      ),
    );
  }

  void handleSignup(AuthViewModel vm) async {
    if (!_agreeToTerms) {
      _showSnackBar("Please agree to Terms and Conditions");
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();

    try {
      final success = await vm.signup(email, password, fullName);
      if (success) {
        _showSnackBar("Account created successfully!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        _showSnackBar("Signup failed.");
      }
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('SIGN UP',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textDark,
            )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create your account',
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.w600, color: textDark)),
              const SizedBox(height: 8),
              Text('Join PinjamTech community today',
                  style: GoogleFonts.poppins(fontSize: 14, color: textLight)),
              const SizedBox(height: 30),

              // Full Name
              Text('Full Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: textDark)),
              const SizedBox(height: 8),
              TextFormField(controller: _fullNameController, decoration: InputDecoration(
                hintText: 'Enter your full name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              )),

              const SizedBox(height: 20),
              // Email
              Text('Email Address', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: textDark)),
              const SizedBox(height: 8),
              TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: 'your.email@example.com',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 20),
              // Password
              Text('Password', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: textDark)),
              const SizedBox(height: 8),
              TextFormField(controller: _passwordController, obscureText: true,
                decoration: InputDecoration(hintText: 'Create a strong password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 8),
              Text('Use at least 8 characters with letters and numbers',
                  style: GoogleFonts.poppins(fontSize: 12, color: textLight)),
              const SizedBox(height: 20),

              // Terms Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    activeColor: primaryBlue,
                    onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                  ),
                  Expanded(child: Text('I agree to the Terms of Service and Privacy Policy', style: GoogleFonts.poppins())),
                ],
              ),
              const SizedBox(height: 30),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: vm.isLoading ? null : () => handleSignup(vm),
                  child: vm.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
