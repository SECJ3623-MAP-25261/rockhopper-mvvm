import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/device_model.dart';

class RentingCartService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Add device to cart
  Future<void> addToCart({
    required Device device,
    required DateTime startDate,
    required DateTime endDate,
    required int quantity,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // 1️⃣ Get the user's cart or create a new one
    var cart = await supabase
        .from('carts')
        .select('id')
        .eq('renter_id', user.id)
        .maybeSingle();

    String cartId;
    if (cart == null) {
      final newCart = await supabase
          .from('carts')
          .insert({'renter_id': user.id})
          .select('id')
          .single();
      cartId = newCart['id'];
    } else {
      cartId = cart['id'];
    }

    // 2️⃣ Insert into cart_items
    await supabase.from('cart_items').insert({
      'cart_id': cartId,
      'listing_id': device.id,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'quantity': quantity,
      'location': device.location ?? '',
      'user_id': user.id, // ✅ Must include!
    });
  }

  /// Fetch cart items for the current user
  Future<List<Map<String, dynamic>>> fetchCartItems() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final cart = await supabase
        .from('carts')
        .select('id')
        .eq('renter_id', user.id)
        .maybeSingle();

    if (cart == null) return [];

    final items = await supabase
        .from('cart_items')
        .select('''
          id,
          cart_id,
          listing_id,
          start_date,
          end_date,
          rental_days,
          quantity,
          location,
          listings: listing_id (
            id,
            name,
            rentee_id,
            price_per_day,
            max_rental_days,
            location
          )
        ''')
        .eq('cart_id', cart['id']);

    return List<Map<String, dynamic>>.from(items);
  }

  /// Remove a single item from cart
  Future<void> removeItem(String cartItemId) async {
    await supabase.from('cart_items').delete().eq('id', cartItemId);
  }

  /// Clear all items in a cart
  Future<void> clearCart(String cartId) async {
    await supabase.from('cart_items').delete().eq('cart_id', cartId);
  }
}
