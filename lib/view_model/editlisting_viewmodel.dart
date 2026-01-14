import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/listing_service.dart';

class EditListingViewModel extends ChangeNotifier {
  final ListingService _service = ListingService();

  Device device;
  List<DateTime> _bookedSlots;
  DateTime _focusedDay;

  EditListingViewModel({required this.device})
      : _bookedSlots = device.bookedSlots,
        _focusedDay = DateTime.now();

  // ================= GETTERS =================
  bool get isAvailable => device.isAvailable;
  List<DateTime> get bookedSlots => _bookedSlots;
  DateTime get focusedDay => _focusedDay;

  // ================= SETTERS =================
  void updateFocusedDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  void updateBookedSlots(List<DateTime> slots) {
    _bookedSlots = slots;
    notifyListeners();
  }

  void updateDevice(Device newDevice) {
    device = newDevice;
    notifyListeners();
  }

  // ================= CRUD =================
  Future<void> deleteListing(BuildContext context) async {
    try {
      await _service.deleteDevice(device.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${device.name} deleted"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> saveChanges(BuildContext context) async {
    try {
      await _service.updateListing(device);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${device.name} updated successfully"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $e"), backgroundColor: Colors.red),
      );
    }
  }
}
