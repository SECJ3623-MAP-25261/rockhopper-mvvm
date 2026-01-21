// lib/core/auth_helper.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthHelper {
  static String? get currentUserId {
    return Supabase.instance.client.auth.currentUser?.id;
  }
  
  static bool get isLoggedIn {
    return Supabase.instance.client.auth.currentUser != null;
  }
}