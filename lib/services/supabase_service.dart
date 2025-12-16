import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // SIGN UP
  Future<AuthResponse> signUp(String email, String password, String fullName) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
      },
    );
  }

  // SIGN IN WITH EMAIL + PASSWORD
  Future<AuthResponse> signInWithPassword(String email, String password) {
  return _supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );
}

  // GOOGLE SIGN-IN
  Future<AuthResponse?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    return await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );
  }

  // RESTORE SESSION (BIOMETRIC)
  Future<Session?> restoreSession(String refreshToken) async {
    final response =
        await _supabase.auth.recoverSession(refreshToken);
    return response.session;
  }

  User? currentUser() => _supabase.auth.currentUser;

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _supabase.auth.signOut();
  }
}
extension UserExtension on User {
  Session? get session => Supabase.instance.client.auth.currentSession;
}
