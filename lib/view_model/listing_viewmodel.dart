import 'dart:io';
import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/image_service.dart';
import '../services/listing_service.dart';
import '../services/location_service.dart';

class CreateListViewModel extends ChangeNotifier {
  final ListingService _listingService = ListingService();
  final ImageService _imageService = ImageService();
  final LocationService _locationService = LocationService();

  bool isPublishing = false;
  bool isAvailable = true;
  String? category;
  String condition = 'Good';
  String maxDays = '30';

  File? selectedImage;
  String locationMessage = 'Location not set';

  Future<void> getLocation() async {
    final position = await _locationService.getCurrentLocation();
    locationMessage =
        'Lat: ${position.latitude}, Long: ${position.longitude}';
    notifyListeners();
  }

  Future<void> publishListing({
    required String name,
    required String brand,
    required double price,
    double? deposit,
    required String description,
    required String specification,
    required String location,
  }) async {
    isPublishing = true;
    notifyListeners();

    String imageUrl =
        'https://via.placeholder.com/400x300?text=$name';

    if (selectedImage != null) {
      imageUrl = await _imageService.uploadImage(selectedImage!) ?? imageUrl;
    }

    final device = Device(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      brand: brand.isEmpty ? 'Generic' : brand,
      pricePerDay: price,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
      maxRentalDays: int.parse(maxDays),
      condition: condition,
      description: description,
      category: category ?? 'General',
      bookedSlots: [],
      deposit: deposit,
      specifications: specification,
      location: location,
    );

    await _listingService.createListing(device);

    isPublishing = false;
    notifyListeners();
  }
}
