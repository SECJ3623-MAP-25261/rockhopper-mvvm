import 'package:supabase_flutter/supabase_flutter.dart';

class RentingCartService {
  final SupabaseClient supabase = Supabase.instance.client;

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
          listing_id,
          start_date,
          end_date,
          listings (
            id,
            name,
            price_per_day,
            description,
            image_url
          )
        ''')
        .eq('cart_id', cart['id']);

    return List<Map<String, dynamic>>.from(items);
  }

  Future<void> removeItem(String cartItemId) async {
    await supabase
        .from('cart_items')
        .delete()
        .eq('id', cartItemId);
  }
}
