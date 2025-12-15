import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/device_model.dart';

class ListingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// ===============================
  /// CREATE LISTING
  /// ===============================
  Future<void> createListing(Device device) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _supabase.from('listings').insert({
      'id': device.id,
      'name': device.name,
      'brand': device.brand,
      'price_per_day': device.pricePerDay,
      'deposit': device.deposit,
      'category': device.category,
      'condition': device.condition,
      'is_available': device.isAvailable,
      'max_rental_days': device.maxRentalDays,
      'description': device.description,
      'specifications': device.specifications,
      'location': device.location,
      'image_url': device.imageUrl,
      'booked_slots': device.bookedSlots,
      'user_id': userId,
    });
  }

  /// ===============================
  /// FETCH DEVICES BY CURRENT USER
  /// (Rentee listings)
  /// ===============================
  Future<List<Device>> fetchDevicesByCurrentUser() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('listings')
        .select()
        .eq('user_id', userId);

    return (response as List)
        .map((item) => DeviceMapper.fromMap(item))
        .toList();
  }

  /// ===============================
  /// FETCH DEVICES BY USER ID
  /// ===============================
  Future<List<Device>> fetchDevicesByUser(String? userId) async {
    if (userId == null) return [];

    final response = await _supabase
        .from('listings')
        .select()
        .eq('user_id', userId);

    return (response as List)
        .map((item) => DeviceMapper.fromMap(item))
        .toList();
  }

  /// ===============================
  /// FETCH AVAILABLE DEVICES
  /// (For renters)
  /// ===============================
  Future<List<Device>> fetchAvailableDevices() async {
    final response = await _supabase
        .from('listings')
        .select()
        .eq('is_available', true);

    return (response as List)
        .map((item) => DeviceMapper.fromMap(item))
        .toList();
  }

  /// ===============================
  /// DELETE DEVICE (Owner only)
  /// ===============================
  Future<void> deleteDevice(String deviceId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('listings')
        .delete()
        .eq('id', deviceId)
        .eq('user_id', userId);
  }
}
