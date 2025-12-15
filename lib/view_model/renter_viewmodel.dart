import 'package:flutter/material.dart';
import '../../models/device_model.dart';
import '../../services/rentee_service.dart';

class RenterHomeViewModel extends ChangeNotifier {
  final ListingService _service = ListingService();

  List<Device> devices = [];
  bool isLoading = true;

  Future<void> loadAvailableDevices() async {
    isLoading = true;
    notifyListeners();

    devices = await _service.fetchAvailableDevices();

    isLoading = false;
    notifyListeners();
  }
}
