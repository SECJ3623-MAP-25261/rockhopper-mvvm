import 'package:flutter/material.dart';
import '../../../models/device_model.dart';
import 'package:pinjamtech_app/services/rentee_service.dart';
import 'package:pinjamtech_app/services/listing_service.dart';


//rentee_home_viewmodel
class RenteeHomeViewModel extends ChangeNotifier {
  final RenteeHomeService _service = RenteeHomeService();

  bool isLoading = true;
  List<Device> devices = [];

  RenteeHomeViewModel() {
    loadDevices();
  }

  Future<void> loadDevices() async {
    isLoading = true;
    notifyListeners();

    devices = await _service.fetchMyListings();

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteDevice(Device device) async {
    await _service.deleteListing(device.id);
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



//rentee viewmodel
class RenteeViewModel extends ChangeNotifier {
  final ListingService _service = ListingService();

  List<Device> devices = [];
  bool isLoading = true;

  Future<void> loadDevices() async {
    isLoading = true;
    notifyListeners();

    devices = await _service.fetchDeviceByUser();

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteDevice(Device device) async {
    await _service.deleteDevice(device.id);
    devices.removeWhere((d) => d.id == device.id);
    notifyListeners();
  }
}

class RenteeMainViewModel extends ChangeNotifier {
  int currentIndex = 0;

  void changeTab(int index) {
    currentIndex = index;
    notifyListeners();
  }
}
