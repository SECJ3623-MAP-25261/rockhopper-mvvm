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
    _authenticate();
  }

  Future<void> _authenticate() async {
    await context.read<AppLockViewModel>().unlockApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _authenticate,
          child: const Text('Unlock with Biometrics'),
        ),
      ),
    );
  }
}
