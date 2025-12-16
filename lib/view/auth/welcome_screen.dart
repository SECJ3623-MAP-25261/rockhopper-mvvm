// lib/view/auth/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart' as auth_login;
import 'signup_screen.dart' as auth_signup;

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textLight = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Pinjam', style: GoogleFonts.poppins(fontSize: 42, fontWeight: FontWeight.w800, color: primaryGreen)),
                  Text('Tech', style: GoogleFonts.poppins(fontSize: 42, fontWeight: FontWeight.w800, color: primaryBlue)),
                ],
              ),
              const SizedBox(height: 16),
              Text('Rent anything, anytime.', style: GoogleFonts.poppins(fontSize: 18, color: textLight)),
              const SizedBox(height: 60),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const auth_login.LoginScreen()),
                    );
                  },
                  child: Text('Log In', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 20),

              // Divider
              Row(children: const [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR')), Expanded(child: Divider())]),
              const SizedBox(height: 20),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const auth_signup.SignUpScreen()),
                    );
                  },
                  child: Text('Sign Up', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: primaryBlue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
