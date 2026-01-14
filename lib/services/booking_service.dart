import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class BookingService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Checkout cart: create bookings and clear cart
  Future<void> checkoutCart() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // 1️⃣ Get cart for this renter
    final cart = await supabase
        .from('carts')
        .select('id')
        .eq('renter_id', user.id)
        .maybeSingle();

    if (cart == null) {
      throw Exception('No cart found');
    }
    final cartId = cart['id'] as String;

    // 2️⃣ Fetch all cart_items
    final cartItems = await supabase
        .from('cart_items')
        .select('id, listing_id, start_date, end_date, rental_days, quantity, location')
        .eq('cart_id', cartId);

    if (cartItems.isEmpty) {
      throw Exception('Cart is empty');
    }

    for (final item in cartItems) {
      final listingId = item['listing_id'] as String;

      // 3️⃣ Fetch listing info
      final listingResp = await supabase
          .from('listings')
          .select('id, name, price_per_day, rentee_id, booked_slots')
          .eq('id', listingId)
          .maybeSingle();

      if (listingResp == null) continue; // skip if listing not found

      final renteeId = listingResp['rentee_id'] as String;
      final pricePerDay = listingResp['price_per_day'] as int;
      final listingName = listingResp['name'] as String;
      final rentalDays = item['rental_days'] as int;
      final totalPrice = rentalDays * pricePerDay;
      final startDate = item['start_date'] as String;
      final endDate = item['end_date'] as String;

      // 4️⃣ Insert into bookings
      await supabase.from('bookings').insert({
        'renter_id': user.id,
        'rentee_id': renteeId,
        'listing_id': listingId,
        'listing_name': listingName,
        'price_per_day': pricePerDay,
        'rental_days': rentalDays,
        'total_price': totalPrice,
        'start_date': startDate,
        'end_date': endDate,
        'status': 'pending', // or 'paid'
      });

      // 5️⃣ Update booked_slots in listing (optional)
      final bookedSlots = (listingResp['booked_slots'] as List<dynamic>? ?? []);

      DateTime start = DateTime.parse(startDate);
      DateTime end = DateTime.parse(endDate);

      for (DateTime d = start; d.isBefore(end.add(const Duration(days:1))); d = d.add(const Duration(days: 1))) {
        bookedSlots.add(DateFormat('yyyy-MM-dd').format(d));
      }

      await supabase.from('listings').update({'booked_slots': bookedSlots}).eq('id', listingId);
    }

    // 6️⃣ Delete cart items
    await supabase.from('cart_items').delete().eq('cart_id', cartId);
  }

 Future<List<Map<String, dynamic>>> getUserBookings() async {
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  try {
    final data = await supabase
        .from('bookings')
        .select()
        .eq('renter_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data as List);
  } catch (e) {
    throw Exception('Error fetching bookings: $e');
  }
}


}
