/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/supabase_service.dart';
//import 'otp_verification_screen.dart';
import 'otp_screen.dart';
import 'forgot_password.dart';
//import '../home/home_roles/renter_home.dart';
import '../home/preferencefilter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final auth = AuthService();
  
  // Colors from welcome screen
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);

  // -----------------------------
  // LOGIN WITH SUPABASE
  // -----------------------------
  void handleLogin() async {
    try {
      final res = await auth.signInWithPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      print("Logged in: ${res.user!.id}");
      _showSnackBar("Login successful!");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>  PreferenceFilteredScreen(),
        ),
      );
    } catch (e) {
      print("Login error: $e");
      _showSnackBar(e.toString());
    }
  }

  // -----------------------------
  // MAIN WIDGET BUILD()
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // WELCOME BACK with consistent font
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

              // Email Label
              Text(
                'Email',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),

              // Email Input
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: GoogleFonts.poppins(color: textLight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: primaryBlue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: GoogleFonts.poppins(color: textDark),
              ),
              const SizedBox(height: 16),

              // Continue with code
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    final email = _emailController.text.trim();
                    if (email.isEmpty) {
                      _showSnackBar('Please enter your email first');
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtpScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Continue with code',
                    style: GoogleFonts.poppins(
                      color: primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password Label
              Text(
                'Password',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),

              // Password Input
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: GoogleFonts.poppins(color: textLight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: primaryBlue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: GoogleFonts.poppins(color: textDark),
              ),
              const SizedBox(height: 16),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPassword(),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot password?',
                    style: GoogleFonts.poppins(
                      color: primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // DONE Button
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 120,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'DONE',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white, // White text
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // SnackBar helper
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: primaryBlue,
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
*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pinjamtech_app/view_model/auth_viewmodel.dart';
import 'forgot_password.dart';
import 'otp_screen.dart';
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

    try {
      await authVM.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PreferenceFilteredScreen()),
      );
    } catch (_) {
      _showSnackBar(authVM.errorMessage ?? "Login failed");
    }
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

              TextButton(
                onPressed: () {
                  if (_emailController.text.isEmpty) {
                    _showSnackBar("Enter email first");
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OtpScreen()),
                  );
                },
                child: Text("Continue with code",
                    style: GoogleFonts.poppins(color: primaryBlue)),
              ),

              const SizedBox(height: 10),

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
