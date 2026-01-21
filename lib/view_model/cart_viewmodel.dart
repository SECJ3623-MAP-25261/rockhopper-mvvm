import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RentingCartViewModel extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  bool isLoading = false;
  List<Map<String, dynamic>> cartItems = [];

  // Load all cart items for the current user
  Future<void> loadCart() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final data = await supabase
          .from('cart_items')
          .select('*, listings(*)') // fetch linked listings
          .eq('user_id', user.id);

      cartItems = List<Map<String, dynamic>>.from(data as List);
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // Remove an item from the cart
  Future<void> removeItem(String id) async {
    try {
      await supabase.from('cart_items').delete().eq('id', id);
      cartItems.removeWhere((item) => item['id'] == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing cart item: $e');
    }
  }

  // Toggle selection for checkout
  void toggleSelection(int index, bool selected) {
    cartItems[index]['selected'] = selected;
    notifyListeners();
  }

  // Calculate total price for selected items
  double get totalPrice {
    double total = 0;
    for (var item in cartItems) {
      if (item['selected'] == true) {
        final listing = item['listings'];
        final price = listing?['price_per_day'] ?? 0;
        final days = item['rental_days'] ?? 1;
        total += price * days;
      }
    }
    return total;
  }
}
