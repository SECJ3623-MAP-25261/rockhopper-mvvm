import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/app_lock_viewmodel.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Automatically trigger biometric auth
      context.read<AppLockViewModel>().unlockApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.read<AppLockViewModel>().unlockApp(),
          child: const Text('Unlock with Biometrics'),
        ),
      ),
    );
  }
}
