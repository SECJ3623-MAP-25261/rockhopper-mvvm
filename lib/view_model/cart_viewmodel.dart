import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/device_model.dart';
import '../../models/cart_item.dart';
import '../services/add_item_service.dart';
import '../services/rentingcart_service.dart';

/// ViewModel for selecting rental dates and building CartItem
class AddItemViewModel extends ChangeNotifier {
  final Device device;
  final AddItemService _service = AddItemService();

  AddItemViewModel(
    this.device, {
    DateTime? start,
    DateTime? end,
  }) {
    selectedStartDate = start;
    selectedEndDate = end;
    if (start != null) focusedDay = start;
  }

  DateTime focusedDay = DateTime.now();
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  CalendarFormat calendarFormat = CalendarFormat.month;
  RangeSelectionMode rangeSelectionMode = RangeSelectionMode.toggledOn;

  int get totalDays {
    if (selectedStartDate == null || selectedEndDate == null) return 0;
    return selectedEndDate!.difference(selectedStartDate!).inDays + 1;
  }

  double get totalPrice => totalDays * device.pricePerDay;

  /// Checks if a date is available for booking
  bool isBookable(DateTime date) => _service.isDateBookable(device, date);

  /// Handles day selection logic for calendar
  void onDaySelected(DateTime day) {
    if (selectedStartDate == null) {
      selectedStartDate = day;
      selectedEndDate = null;
    } else if (selectedEndDate == null && day.isAfter(selectedStartDate!)) {
      selectedEndDate = day;
    } else {
      selectedStartDate = day;
      selectedEndDate = null;
    }
    focusedDay = day;
    notifyListeners();
  }

  /// Suggest next available date
  void suggestDates() {
    final next = _service.getNextAvailableDate(device, DateTime.now());
    selectedStartDate = next;
    selectedEndDate = next;
    focusedDay = next;
    notifyListeners();
  }

  /// Builds a CartItem from selected device and dates
  CartItem buildCartItem() {
    if (selectedStartDate == null || selectedEndDate == null) {
      throw Exception("Start and end dates must be selected");
    }
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
      location: device.location ?? "", // ensure non-null
    );
  }
}

/// ViewModel for Renting Cart
class RentingCartViewModel extends ChangeNotifier {
  final RentingCartService _service = RentingCartService();

  bool isLoading = true;
  List<Map<String, dynamic>> cartItems = [];

  RentingCartViewModel() {
    loadCart();
  }

  /// Fetch cart items from service
  Future<void> loadCart() async {
    isLoading = true;
    notifyListeners();

    final items = await _service.fetchCartItems();

    cartItems = items
        .map((item) => {
              ...item,
              'selected': false, // UI selection state
            })
        .toList();

    isLoading = false;
    notifyListeners();
  }

  /// Toggle selection of an item in UI
  void toggleSelection(int index, bool value) {
    if (index < 0 || index >= cartItems.length) return;
    cartItems[index]['selected'] = value;
    notifyListeners();
  }

  /// Calculates total price for selected items
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

  /// Remove item from cart
  Future<void> removeItem(String cartItemId) async {
    await _service.removeItem(cartItemId);
    await loadCart();
  }
}
