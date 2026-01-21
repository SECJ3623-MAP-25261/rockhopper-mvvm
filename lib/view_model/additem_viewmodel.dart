import 'package:flutter/material.dart';
import '../models/device_model.dart';
import 'package:pinjamtech_app/services/rentingcart_service.dart';

class AddItemViewModel extends ChangeNotifier {
  final Device device;
  final RentingCartService _service = RentingCartService();

  int quantity = 1;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? focusedDay;
  bool isLoading = false;

  AddItemViewModel({required this.device});

  void setQuantity(int q) {
    quantity = q;
    notifyListeners();
  }

  /// Called when user selects a day in TableCalendar
  void onDaySelected(DateTime selectedDay) {
    if (startDate == null || (startDate != null && endDate != null)) {
      startDate = selectedDay;
      endDate = null;
    } else if (startDate != null && endDate == null) {
      if (selectedDay.isBefore(startDate!)) {
        endDate = startDate;
        startDate = selectedDay;
      } else {
        endDate = selectedDay;
      }
    }
    focusedDay = selectedDay;
    notifyListeners();
  }

  Future<void> addToCart() async {
    if (startDate == null || endDate == null) {
      throw Exception('Please select rental dates');
    }

    isLoading = true;
    notifyListeners();

    try {
      await _service.addToCart(
        device: device,
        startDate: startDate!,
        endDate: endDate!,
        quantity: quantity,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
