// lib/services/google_auth_service.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '978902264854-frpijae785tns6g4vr05neq0tmetkggl.apps.googleusercontent.com',
  );

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      
      if (googleAuth.idToken == null) {
        throw Exception('No ID token received from Google');
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}