import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pinjamtech_app/models/device_model.dart';

class ListingService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Fetch all devices created by the current rentee
  Future<List<Device>> fetchMyListings() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('listings')
        .select()
        .eq('user_id', userId);

    return (response as List<dynamic>)
        .map((item) => Device.fromMap(item))
        .toList();
  }

  /// Delete a listing created by the current rentee
  Future<void> deleteListing(String deviceId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase
        .from('listings')
        .delete()
        .eq('id', deviceId)
        .eq('user_id', userId);
  }

  /// Fetch all available devices (for renters)
  Future<List<Device>> fetchAvailableDevices() async {
    final response = await supabase
        .from('listings')
        .select()
        .eq('is_available', true);

    return (response as List<dynamic>)
        .map((item) => Device.fromMap(item))
        .toList();
  }

  /// Optional: Fetch devices by a specific user (rentee)
  Future<List<Device>> fetchDevicesByUser(String? userId) async {
    if (userId == null) return [];
    final response = await supabase
        .from('listings')
        .select()
        .eq('user_id', userId);

    return (response as List<dynamic>)
        .map((item) => Device.fromMap(item))
        .toList();
  }
}
