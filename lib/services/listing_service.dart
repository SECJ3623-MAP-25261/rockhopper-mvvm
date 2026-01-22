/*import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/device_model.dart';
import 'dart:convert';


class ListingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// CREATE LISTING
  
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
    'rentee_id': userId, // ✅ updated here
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
      .eq('rentee_id', userId); // ✅ updated here

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
      .eq('rentee_id', userId); // ✅ updated here

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
      .eq('rentee_id', userId); // ✅ updated here
}
Future<void> updateDevice(Device device) async {
  final userId = _supabase.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');

  await _supabase
      .from('listings')
      .update({
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
        'updated_at': DateTime.now().toIso8601String(), // Add update timestamp
      })
      .eq('id', device.id)
      .eq('rentee_id', userId); // Ensure only owner can update
}

}
*/

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/device_model.dart';
import 'dart:convert';

class ListingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// CREATE LISTING
  Future<void> createListing(Device device) async {
    try {
      final data = {
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
        'booked_slots': jsonEncode(device.bookedSlots.map((d) => d.toIso8601String()).toList()),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      print('📤 Creating listing in Supabase:');
      print('   Data: $data');
      
      await _supabase.from('listings').insert(data);
      
      print('✅ Listing created successfully');
    } catch (e) {
      print('❌ Error creating listing: $e');
      rethrow;
    }
  }

  /// FETCH DEVICES BY CURRENT USER
  Future<List<Device>> fetchDevicesByCurrentUser() async {
    try {
      print('📥 Fetching all listings (no user filtering)');
      
      final response = await _supabase
          .from('listings')
          .select()
          .order('created_at', ascending: false);
      
      print(' Fetched ${response.length} listings');
      
      return (response as List).map((e) => Device.fromMap(e)).toList();
    } catch (e) {
      print(' Error fetching listings: $e');
      return [];
    }
  }

  /// FETCH AVAILABLE DEVICES
  Future<List<Device>> fetchAvailableDevices() async {
    try {
      print(' Fetching available listings');
      
      final response = await _supabase
          .from('listings')
          .select()
          .eq('is_available', true)
          .order('created_at', ascending: false);
      
      print(' Fetched ${response.length} available listings');
      
      return (response as List).map((e) => Device.fromMap(e)).toList();
    } catch (e) {
      print(' Error fetching available listings: $e');
      return [];
    }
  }

  /// DELETE DEVICE
  Future<void> deleteDevice(String deviceId) async {
    try {
      print('🗑️ Deleting listing: $deviceId');
      
      // Remove .eq('user_id', userId) since column doesn't exist
      await _supabase.from('listings').delete().eq('id', deviceId);
      
      print(' Listing deleted successfully');
    } catch (e) {
      print(' Error deleting listing: $e');
      rethrow;
    }
  }

  /// ================= EDIT / UPDATE LISTING =================
  Future<void> updateListing(Device device) async {
    try {
      print('📝 Updating listing: ${device.id}');
      
      final data = {
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
        'booked_slots': jsonEncode(device.bookedSlots.map((d) => d.toIso8601String()).toList()),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      print('   Update data: $data');
      
      // Remove .eq('user_id', userId) since column doesn't exist
      await _supabase.from('listings').update(data).eq('id', device.id);
      
      print(' Listing updated successfully');
    } catch (e) {
      print(' Error updating listing: $e');
      rethrow;
    }
  }
}