import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to login',
        biometricOnly: true,
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> storeSession({
    required String email,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'user_email', value: email);
    await _storage.write(
      key: 'supabase_refresh_token',
      value: refreshToken,
    );
  }

  Future<String?> getEmail() async {
    return _storage.read(key: 'user_email');
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: 'supabase_refresh_token');
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
