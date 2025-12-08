// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // ---------------- GET THE USER'S NAME  ----------------
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // ---------------- SIGN UP ----------------
  Future<AuthResponse> signUp(String email, String password, String fullName) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
      },
    );
  }

  // ---------------- EMAIL + PASSWORD LOGIN ----------------
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ---------------- OTP LOGIN (EMAIL CODE) tak jadi ----------------
  Future<void> sendOtp(String email) async {
    return await supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'io.supabase.flutter://signin-callback/',
    );
  }

  // ---------------- SEND PASSWORD RESET EMAIL ----------------
  Future<void> sendPasswordResetEmail(String email, {String? redirectTo}) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo,
    );
  }

  // ---------------- UPDATE PASSWORD ----------------
  Future<UserResponse> updatePassword(String newPassword) async {
    final res = await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    return res;
  }

  // ---------------- LOGOUT ----------------
  Future<void> signOut() async {
   await supabase.auth.signOut();
}


}
