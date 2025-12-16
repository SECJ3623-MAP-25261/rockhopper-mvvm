import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'view/auth/welcome_screen.dart';

// ViewModels
import 'viewmodel/auth_viewmodel.dart';

// Services
import 'services/supabase_service.dart';
import 'services/biometric_service.dart';
import 'services/google_auth_service.dart';

// UI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://moaqfxollzcqizdbquvy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vYXFmeG9sbHpjcWl6ZGJxdXZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ5MDgyMDQsImV4cCI6MjA4MDQ4NDIwNH0.LGAgzASzGXXeNtNQ___yH9JscUeVnmxi7SSbFJlsucQ',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(
            AuthService(),
            BiometricService(),
            GoogleAuthService(),
          )..init(),
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PinjamTech',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WelcomeScreen(),
    );
  }
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final vm = context.read<AuthViewModel>();
      if (vm.currentUser != null) {
        await vm.loginWithBiometrics();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PinjamTech',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}