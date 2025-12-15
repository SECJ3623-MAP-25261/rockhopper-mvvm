import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pinjamtech_app/models/device_model.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class CreateListingViewModel extends ChangeNotifier {
  // Controllers
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController depositController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController specificationController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController brandController = TextEditingController();

  // Form state
  String? selectedCategory;
  String? selectedCondition = 'Good';
  String? selectedMaxDays = '30';
  bool isAvailable = true;

  // Image state
  File? selectedImage;

  // Location state
  Position? currentPosition;
  String locationMessage = 'Location not set';
  bool isLoadingLocation = false;

  // Publishing state
  bool isPublishing = false;

  @override
  void dispose() {
    itemNameController.dispose();
    priceController.dispose();
    depositController.dispose();
    descriptionController.dispose();
    specificationController.dispose();
    locationController.dispose();
    brandController.dispose();
    super.dispose();
  }

  // ============ SETTERS ============
  void setCategory(String? value) {
    selectedCategory = value;
    notifyListeners();
  }

  void setCondition(String? value) {
    selectedCondition = value;
    notifyListeners();
  }

  void setMaxDays(String? value) {
    selectedMaxDays = value;
    notifyListeners();
  }

  void setAvailability(bool value) {
    isAvailable = value;
    notifyListeners();
  }

  void setImage(File? image) {
    selectedImage = image;
    notifyListeners();
  }

  // ============ LOCATION METHODS ============
  Future<LocationResult> getCurrentLocation() async {
    isLoadingLocation = true;
    notifyListeners();

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isLoadingLocation = false;
        locationMessage = 'Location services are disabled';
        notifyListeners();
        return LocationResult.serviceDisabled;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isLoadingLocation = false;
          locationMessage = 'Location permission denied';
          notifyListeners();
          return LocationResult.permissionDenied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        isLoadingLocation = false;
        locationMessage = 'Location permission permanently denied';
        notifyListeners();
        return LocationResult.permissionDeniedForever;
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentPosition = position;
      locationMessage = 'Lat: ${position.latitude.toStringAsFixed(6)}, Long: ${position.longitude.toStringAsFixed(6)}';
      locationController.text = locationMessage;
      isLoadingLocation = false;
      notifyListeners();

      return LocationResult.success;
    } catch (e) {
      isLoadingLocation = false;
      locationMessage = 'Error getting location';
      notifyListeners();
      return LocationResult.error;
    }
  }

  // ============ IMAGE UPLOAD ============
  Future<String?> uploadImageToSupabase(File image) async {
    final supabase = Supabase.instance.client;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';

    try {
      await supabase.storage.from('listing-images').upload(
        fileName,
        image,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final publicUrl = supabase.storage.from('listing-images').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Image upload error: $e');
      return null;
    }
  }

  // ============ VALIDATION ============
  ValidationResult validateForm() {
    if (itemNameController.text.isEmpty) {
      return ValidationResult(false, 'Item name is required');
    }

    if (priceController.text.isEmpty) {
      return ValidationResult(false, 'Price is required');
    }

    if (selectedCategory == null) {
      return ValidationResult(false, 'Category is required');
    }

    final price = double.tryParse(priceController.text);
    if (price == null || price <= 0) {
      return ValidationResult(false, 'Please enter a valid price');
    }

    return ValidationResult(true, 'Valid');
  }

  // ============ PUBLISH LISTING ============
  Future<PublishResult> publishListing() async {
    if (isPublishing) {
      return PublishResult(false, 'Already publishing');
    }

    // Validate form
    final validation = validateForm();
    if (!validation.isValid) {
      return PublishResult(false, validation.message);
    }

    isPublishing = true;
    notifyListeners();

    try {
      // Upload image
      String imageUrl = 'https://via.placeholder.com/400x300?text=${Uri.encodeComponent(itemNameController.text)}';
      
      if (selectedImage != null) {
        final uploadedUrl = await uploadImageToSupabase(selectedImage!);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      // Create device object
      final newDevice = Device(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: itemNameController.text.trim(),
        brand: brandController.text.trim().isNotEmpty 
            ? brandController.text.trim() 
            : 'Generic',
        pricePerDay: double.parse(priceController.text),
        imageUrl: imageUrl,
        isAvailable: isAvailable,
        maxRentalDays: int.tryParse(selectedMaxDays ?? '30') ?? 30,
        condition: selectedCondition ?? 'Good',
        description: descriptionController.text.trim(),
        category: selectedCategory ?? 'General',
        bookedSlots: [],
        deposit: double.tryParse(depositController.text),
        specifications: specificationController.text.trim(),
        location: locationController.text.trim().isNotEmpty 
            ? locationController.text.trim() 
            : locationMessage,
      );

      // Save to Supabase
      await _saveToSupabase(newDevice);

      isPublishing = false;
      notifyListeners();

      return PublishResult(true, 'Listing published successfully!', device: newDevice);
    } catch (e) {
      isPublishing = false;
      notifyListeners();
      return PublishResult(false, 'Failed to publish: $e');
    }
  }

  // ============ SUPABASE SAVE ============
  Future<void> _saveToSupabase(Device newDevice) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User not logged in');
    }

    await supabase.from('listings').insert({
      'id': newDevice.id,
      'name': newDevice.name,
      'brand': newDevice.brand,
      'price_per_day': newDevice.pricePerDay,
      'deposit': newDevice.deposit,
      'category': newDevice.category,
      'condition': newDevice.condition,
      'is_available': newDevice.isAvailable,
      'max_rental_days': newDevice.maxRentalDays,
      'description': newDevice.description,
      'specifications': newDevice.specifications,
      'location': newDevice.location,
      'image_url': newDevice.imageUrl,
      'booked_slots': newDevice.bookedSlots,
      'user_id': userId,
    });
  }
}

// ============ RESULT CLASSES ============
enum LocationResult {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}

class ValidationResult {
  final bool isValid;
  final String message;

  ValidationResult(this.isValid, this.message);
}

class PublishResult {
  final bool success;
  final String message;
  final Device? device;

  PublishResult(this.success, this.message, {this.device});
}