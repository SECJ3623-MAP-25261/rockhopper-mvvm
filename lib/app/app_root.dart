import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view/security/app_lock_screen.dart';
import '../view/auth/welcome_screen.dart';
import '../view_model/app_lock_viewmodel.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLockViewModel>(
      builder: (context, lock, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PinjamTech',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: lock.isLocked ? const AppLockScreen() : const WelcomeScreen(),
        );
      },
    );
  }
}
