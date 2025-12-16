import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /* -----------------------------
  LOGIN
  ----------------------------- */
Future<void> login({
  required String email,
  required String password,
}) async {
  _setLoading(true);
  _setError(null);

  try {
    final res = await _authService.signInWithPassword(email.trim(), password.trim());

    // Check if login succeeded
    if (res.user == null || res.session == null) {
      _setError("Invalid email or password");
      return;
    }

    // Login successful
  } on AuthException catch (e) {
    _setError(e.message);
  } catch (e) {
    _setError("Unexpected error: $e");
  } finally {
    _setLoading(false);
  }
}


  /* -----------------------------
  SIGN UP
  ----------------------------- */
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.signUp(
        email.trim(),
        password.trim(),
        fullName.trim(),
      );
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /* -----------------------------
  FORGOT PASSWORD (SEND TOKEN)
  ----------------------------- */
  Future<void> sendResetToken(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /* -----------------------------
  RESET PASSWORD (VERIFY TOKEN)
  ----------------------------- */
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _supabase.auth.verifyOTP(
        email: email.trim(),
        token: token.trim(),
        type: OtpType.recovery,
      );

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword.trim()),
      );
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
