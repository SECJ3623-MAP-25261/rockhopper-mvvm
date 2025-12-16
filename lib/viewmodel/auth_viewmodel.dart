// lib/viewmodel/auth_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/biometric_service.dart';
import '../services/google_auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final BiometricService _biometricService;
  final GoogleAuthService _googleAuthService;

  AuthViewModel(
      this._authService, this._biometricService, this._googleAuthService);

  bool isLoading = false;
  User? currentUser;

  void init() {
    currentUser = _authService.currentUser();
  }

  /// Email + Password signup
  Future<bool> signup(String email, String password, String fullName) async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await _authService.signUp(email, password, fullName);
      currentUser = res.user;
      return currentUser != null;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Login using Supabase email/password
  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await _authService.signInWithPassword(email, password);
      currentUser = res.user;
      return currentUser != null;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.signOut();
    await _biometricService.clear();
    currentUser = null;
    notifyListeners();
  }

  /// Biometric login (after app is resumed)
  Future<bool> loginWithBiometrics() async {
    try {
      isLoading = true;
      notifyListeners();

      final canAuthenticate = await _biometricService.authenticate();
      if (!canAuthenticate) return false;

      final refreshToken = await _biometricService.getRefreshToken();
      if (refreshToken == null) return false;

      final session = await _authService.restoreSession(refreshToken);
      if (session != null) {
        currentUser = session.user;
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Save session for biometric login
  Future<void> saveSessionForBiometrics(String email, String refreshToken) async {
    await _biometricService.storeSession(
      email: email,
      refreshToken: refreshToken,
    );
  }
}
