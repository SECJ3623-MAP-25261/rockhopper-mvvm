import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool isLoading = true;
  bool isUploading = false;
  String? errorMessage;

  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController bioController;
  String selectedGender = 'Prefer not to say';
  File? selectedImage;

  final List<String> genders = ['Male', 'Female', 'Other', 'Prefer not to say'];

  EditProfileViewModel() {
    fullNameController = TextEditingController();
    phoneController = TextEditingController();
    bioController = TextEditingController();
    loadProfileData();
  }

  /// Load user profile data from Supabase
  Future<void> loadProfileData() async {
    isLoading = true;
    notifyListeners();
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        fullNameController.text = response['full_name'] ?? '';
        phoneController.text =
            response['phone'] ?? user.userMetadata?['phone'] ?? '';
        bioController.text = response['bio'] ?? '';
        selectedGender = response['gender'] ?? 'Prefer not to say';
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Update selected gender
  void setGender(String gender) {
    selectedGender = gender;
    notifyListeners();
  }

  /// Pick profile image
  Future<void> selectImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      selectedImage = File(picked.path);
      notifyListeners();
    }
  }

  /// Upload image to Supabase Storage
  Future<String?> uploadImageToSupabase(File image) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';
    try {
      await _supabase.storage.from('profile-images').upload(
            fileName,
            image,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );
      final publicUrl =
          _supabase.storage.from('profile-images').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Image upload error: $e');
      return null;
    }
  }

  /// Update profile (Supabase Auth + Profiles table)
  Future<void> updateProfile() async {
    isUploading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      String? avatarUrl;
      if (selectedImage != null) {
        avatarUrl = await uploadImageToSupabase(selectedImage!);
      }

      // Update auth user metadata
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullNameController.text.trim(),
            'phone': phoneController.text.trim(),
          },
        ),
      );

      // Update profiles table
      await _supabase.from('profiles').update({
        'full_name': fullNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'gender': selectedGender,
        'bio': bioController.text.trim(),
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);
    } catch (e) {
      errorMessage = 'Update failed: $e';
      debugPrint(errorMessage);
      rethrow;
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.dispose();
  }
}
