/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  final String email;
  const CreateNewPasswordScreen({super.key, required this.email});

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);

  final supabase = Supabase.instance.client;

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
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "RESET PASSWORD",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Text(
                  "Reset Token",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _tokenController,
                  decoration: InputDecoration(
                    hintText: "Enter token from email",
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
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter your reset token" : null,
                ),

                const SizedBox(height: 20),

                Text(
                  "New Password",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Enter new password",
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
                  validator: (v) => v != null && v.length < 6
                      ? "Password must be at least 6 characters"
                      : null,
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "UPDATE PASSWORD",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await supabase.auth.verifyOTP(
        email: widget.email,
        token: _tokenController.text.trim(),
        type: OtpType.recovery,
      );

      await supabase.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Password updated successfully!",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: primaryBlue,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: primaryBlue,
      ),
    );
  }
} 
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinjamtech_app/view_model/auth_viewmodel.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  final String email;
  const CreateNewPasswordScreen({super.key, required this.email});

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _token = TextEditingController();
  final _password = TextEditingController();

  Future<void> _reset() async {
    final authVM = context.read<AuthViewModel>();

    try {
      await authVM.resetPassword(
        email: widget.email,
        token: _token.text,
        newPassword: _password.text,
      );

      if (!mounted) return;
      Navigator.popUntil(context, (r) => r.isFirst);
    } catch (_) {
      _show(authVM.errorMessage ?? "Reset failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _token, decoration: const InputDecoration(labelText: "Token")),
            TextField(controller: _password, decoration: const InputDecoration(labelText: "New Password"), obscureText: true),
            ElevatedButton(
              onPressed: authVM.isLoading ? null : _reset,
              child: authVM.isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Update Password"),
            ),
          ],
        ),
      ),
    );
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
