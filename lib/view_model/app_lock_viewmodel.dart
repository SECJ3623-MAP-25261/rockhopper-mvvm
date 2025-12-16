import 'package:flutter/material.dart';
import '../services/biometric_service.dart';

class AppLockViewModel extends ChangeNotifier {
  final BiometricService biometricService;
  bool _isLocked = false;

  AppLockViewModel(this.biometricService);

  bool get isLocked => _isLocked;

  void lockApp() {
    _isLocked = true;
    print("App locked");
    notifyListeners();
  }

  Future<void> unlockApp() async {
    bool success = await biometricService.authenticate();
    if (success) {
      _isLocked = false;
      print("App unlocked");
      notifyListeners();
    }
  }
}
