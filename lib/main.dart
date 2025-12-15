import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'view/auth/welcome_screen.dart';

// VIEWMODELS
import 'package:pinjamtech_app/view_model/auth_viewmodel.dart';
import 'package:pinjamtech_app/view_model/listing_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://moaqfxollzcqizdbquvy.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vYXFmeG9sbHpjcWl6ZGJxdXZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ5MDgyMDQsImV4cCI6MjA4MDQ4NDIwNH0.LGAgzASzGXXeNtNQ___yH9JscUeVnmxi7SSbFJlsucQ',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CreateListViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PinjamTech',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomeScreen(),
    );
  }
}
