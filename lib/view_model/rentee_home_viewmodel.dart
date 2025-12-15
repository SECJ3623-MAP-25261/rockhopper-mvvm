import 'package:flutter/material.dart';
import '../../../models/device_model.dart';
import 'package:pinjamtech_app/services/listing_service.dart';

/// ===============================
/// Rentee Home ViewModel
/// ===============================
class RenteeHomeViewModel extends ChangeNotifier {
  final ListingService _service = ListingService();

  bool isLoading = true;
  List<Device> devices = [];

  RenteeHomeViewModel() {
    loadDevices();
  }

  Future<void> loadDevices() async {
    isLoading = true;
    notifyListeners();

    devices = await _service.fetchDevicesByCurrentUser();

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteDevice(Device device) async {
    await _service.deleteDevice(device.id);
    devices.removeWhere((d) => d.id == device.id);
    notifyListeners();
  }

  void updateDevice(Device updated) {
    final index = devices.indexWhere((d) => d.id == updated.id);
    if (index != -1) {
      devices[index] = updated;
      notifyListeners();
    }
  }

  void addDevice(Device device) {
    devices.add(device);
    notifyListeners();
  }
}
