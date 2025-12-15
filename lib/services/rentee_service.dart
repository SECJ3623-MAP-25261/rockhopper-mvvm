import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/device_model.dart';

class RenteeHomeService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Device>> fetchMyListings() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('listings')
        .select()
        .eq('user_id', userId);

    return (response as List<dynamic>).map((item) {
      return Device(
        id: item['id'],
        name: item['name'],
        brand: item['brand'] ?? '',
        pricePerDay: (item['price_per_day'] ?? 0).toDouble(),
        imageUrl: item['image_url'] ?? '',
        isAvailable: item['is_available'] ?? true,
        maxRentalDays: item['max_rental_days'] ?? 0,
        condition: item['condition'] ?? '',
        description: item['description'] ?? '',
        category: item['category'] ?? '',
        bookedSlots: (item['booked_slots'] as List<dynamic>?)
                ?.map((e) => DateTime.parse(e))
                .toList() ??
            [],
        deposit: (item['deposit'] as num?)?.toDouble(),
      );
    }).toList();
  }

  Future<void> deleteListing(String deviceId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase
        .from('listings')
        .delete()
        .eq('id', deviceId)
        .eq('user_id', userId);
  }
}
