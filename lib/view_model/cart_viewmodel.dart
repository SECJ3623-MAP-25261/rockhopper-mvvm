import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/device_model.dart';
import '../../models/cart_item.dart';
import '../services/add_item_service.dart';
import '../services/rentingcart_service.dart';

class AddItemViewModel extends ChangeNotifier {
  final Device device;
  final AddItemService _service = AddItemService();

  AddItemViewModel(this.device,
      {DateTime? start, DateTime? end}) {
    selectedStartDate = start;
    selectedEndDate = end;
    if (start != null) focusedDay = start;
  }

  DateTime focusedDay = DateTime.now();
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  CalendarFormat calendarFormat = CalendarFormat.month;
  RangeSelectionMode rangeSelectionMode =
      RangeSelectionMode.toggledOn;

  int get totalDays {
    if (selectedStartDate == null || selectedEndDate == null) {
      return 0;
    }
    return selectedEndDate!
            .difference(selectedStartDate!)
            .inDays +
        1;
  }

  double get totalPrice =>
      totalDays * device.pricePerDay;

  bool isBookable(DateTime date) =>
      _service.isDateBookable(device, date);

  void onDaySelected(DateTime day) {
    if (selectedStartDate == null) {
      selectedStartDate = day;
    } else if (selectedEndDate == null &&
        day.isAfter(selectedStartDate!)) {
      selectedEndDate = day;
    } else {
      selectedStartDate = null;
      selectedEndDate = null;
    }
    notifyListeners();
  }

  void suggestDates() {
    final next =
        _service.getNextAvailableDate(device, DateTime.now());
    selectedStartDate = next;
    selectedEndDate = next;
    focusedDay = next;
    notifyListeners();
  }

  CartItem buildCartItem() {
    return CartItem(
      id: device.id,
      name: device.name,
      price: device.pricePerDay,
      image: device.imageUrl,
      description: device.description,
      condition: device.condition,
      category: device.category,
      startDate: selectedStartDate!,
      endDate: selectedEndDate!,
      brand: device.brand,
      maxRentalDays: device.maxRentalDays,
    );
  }
}

//renting cart view model
class RentingCartViewModel extends ChangeNotifier {
  final RentingCartService _service = RentingCartService();

  bool isLoading = true;
  List<Map<String, dynamic>> cartItems = [];

  RentingCartViewModel() {
    loadCart();
  }

  Future<void> loadCart() async {
    isLoading = true;
    notifyListeners();

    final items = await _service.fetchCartItems();

    cartItems = items
        .map((item) => {
              ...item,
              'selected': false, // UI state
            })
        .toList();

    isLoading = false;
    notifyListeners();
  }

  void toggleSelection(int index, bool value) {
    cartItems[index]['selected'] = value;
    notifyListeners();
  }

  double get totalPrice {
    double total = 0;
    for (final item in cartItems) {
      if (item['selected'] == true) {
        final listing = item['listings'];
        total += (listing?['price_per_day'] ?? 0).toDouble();
      }
    }
    return total;
  }

  Future<void> removeItem(String cartItemId) async {
    await _service.removeItem(cartItemId);
    await loadCart();
  }
}

