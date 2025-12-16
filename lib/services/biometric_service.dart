import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return [];
    }
  }

  Future<bool> authenticate() async {
    try {
      final bool canAuthenticate =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canAuthenticate) return false;

      return await _auth.authenticate(
        localizedReason: "Authenticate to continue",
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      print("Biometric error: $e");
      return false;
    }
  }
}
