import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RenteeProfileViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, dynamic>? profileData;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  RenteeProfileViewModel() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        hasError = true;
        errorMessage = 'User not logged in';
        isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      profileData = response;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  String getDisplayName() {
    final user = _supabase.auth.currentUser;
    final authName = user?.userMetadata?['full_name']?.toString();
    final profileName = profileData?['full_name']?.toString();
    return profileName ?? authName ?? 'No Name';
  }

  String getEmail() => _supabase.auth.currentUser?.email ?? 'No Email';

  String getPhone() {
    final user = _supabase.auth.currentUser;
    final authPhone = user?.userMetadata?['phone']?.toString();
    final profilePhone = profileData?['phone']?.toString();
    return profilePhone ?? authPhone ?? 'No phone';
  }

  String getGender() => profileData?['gender']?.toString() ?? 'Not specified';

  String getBio() => profileData?['bio']?.toString() ?? 'No bio yet';

  String? getAvatarUrl() {
    final url = profileData?['avatar_url']?.toString();
    if (url == null || url.isEmpty) return null;
    // Add cache busting
    return '$url?cacheBust=${DateTime.now().millisecondsSinceEpoch}';
  }

  String getRole() => profileData?['role']?.toString() ?? 'rentee';

  DateTime getJoinDate() {
    try {
      return DateTime.parse(profileData?['created_at'] ?? DateTime.now().toIso8601String());
    } catch (_) {
      return DateTime.now();
    }
  }

  double? getRating() => profileData?['rating'] != null
      ? (profileData!['rating'] as num).toDouble()
      : null;
}
