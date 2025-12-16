import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'app/app_root.dart';
import 'core/app_lifecycle_handler.dart';

// VIEWMODELS
import 'view_model/auth_viewmodel.dart';
import 'view_model/createlist_viewmodel.dart';
import 'view_model/app_lock_viewmodel.dart';

// SERVICES
import 'services/biometric_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://moaqfxollzcqizdbquvy.supabase.co',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CreateListingViewModel()),
        ChangeNotifierProvider(
          create: (_) => AppLockViewModel(BiometricService()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLifecycleHandler(
      child: AppRoot(),
    );
  }
}
