import 'package:flutter/material.dart';
import '../services/biometric_service.dart';

class BiometricViewModel extends ChangeNotifier {
  final BiometricService _biometricService;

  BiometricViewModel(this._biometricService);

  bool _canCheckBiometrics = false;
  bool get canCheckBiometrics => _canCheckBiometrics;

  Future<void> checkBiometricsAvailability() async {
    _canCheckBiometrics = await _biometricService.authenticate();
    notifyListeners();
  }

  Future<bool> authenticate() async {
    try {
      return await _biometricService.authenticate();
    } catch (e) {
      return false;
    }
  }
}
