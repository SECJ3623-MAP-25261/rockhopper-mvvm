import 'package:pinjamtech_app/services/offline_database_service.dart';
import 'package:pinjamtech_app/services/connectivity_service.dart';
import 'package:pinjamtech_app/services/listing_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../models/device_model.dart';

class OfflineManager {
  final OfflineDatabaseService _offlineDb = OfflineDatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  final ListingService _listingService = ListingService();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  static final OfflineManager _instance = OfflineManager._internal();
  factory OfflineManager() => _instance;
  OfflineManager._internal();
  
  Future<Map<String, dynamic>> saveListing({
    required Map<String, dynamic> listingData,
    bool forceOnline = false,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      listingData['user_id'] = user.id;
      
      if (!forceOnline && !(await _connectivity.isConnected)) {
        final localId = await _offlineDb.savePendingListing(listingData);
        
        await _offlineDb.addToSyncQueue(
          operationType: 'create_listing',
          tableName: 'listings',
          data: listingData,
        );
        
        return {
          'success': true,
          'offline': true,
          'local_id': localId,
          'message': 'Listing saved offline. It will sync when you reconnect.',
        };
      } else {
        try {
          final device = _mapToDevice(listingData);
          await _listingService.createListing(device);
          
          return {
            'success': true,
            'offline': false,
            'message': 'Listing published successfully!',
          };
        } catch (onlineError) {
          final localId = await _offlineDb.savePendingListing(listingData);
          
          await _offlineDb.addToSyncQueue(
            operationType: 'create_listing',
            tableName: 'listings',
            data: listingData,
            priority: 1,
          );
          
          return {
            'success': true,
            'offline': true,
            'local_id': localId,
            'message': 'Saved offline due to connection error. Will sync when stable.',
            'error': onlineError.toString(),
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to save listing',
      };
    }
  }
  
  Device _mapToDevice(Map<String, dynamic> data) {
    return Device(
      id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      pricePerDay: (data['price_per_day'] ?? 0.0).toDouble(),
      imageUrl: data['image_url'] ?? '',
      isAvailable: data['is_available'] ?? true,
      maxRentalDays: data['max_rental_days'] ?? 30,
      condition: data['condition'] ?? 'Good',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      bookedSlots: data['booked_slots'] is String 
          ? (jsonDecode(data['booked_slots']) as List).map((e) => DateTime.parse(e.toString())).toList()
          : (data['booked_slots'] as List<dynamic>?)?.map((e) => DateTime.parse(e.toString())).toList() ?? [],
      deposit: (data['deposit'] as num?)?.toDouble(),
      specifications: data['specifications'],
      location: data['location'],
    );
  }
  
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
    bool forceOnline = false,
  }) async {
    try {
      if (!forceOnline && !(await _connectivity.isConnected)) {
        for (final entry in updates.entries) {
          await _offlineDb.savePendingProfileUpdate(
            userId: userId,
            fieldName: entry.key,
            newValue: entry.value,
          );
        }
        
        await _offlineDb.addToSyncQueue(
          operationType: 'update_profile',
          tableName: 'profiles',
          data: {'user_id': userId, ...updates},
          recordId: userId,
        );
        
        return {
          'success': true,
          'offline': true,
          'message': 'Profile updates saved offline. Will sync when reconnected.',
        };
      } else {
        try {
          if (updates.containsKey('full_name') || updates.containsKey('phone')) {
            await _supabase.auth.updateUser(
              UserAttributes(
                data: {
                  if (updates.containsKey('full_name')) 'full_name': updates['full_name'],
                  if (updates.containsKey('phone')) 'phone': updates['phone'],
                },
              ),
            );
          }
          
          await _supabase.from('profiles').update({
            ...updates,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('user_id', userId);
          
          return {
            'success': true,
            'offline': false,
            'message': 'Profile updated successfully!',
          };
        } catch (onlineError) {
          for (final entry in updates.entries) {
            await _offlineDb.savePendingProfileUpdate(
              userId: userId,
              fieldName: entry.key,
              newValue: entry.value,
            );
          }
          
          await _offlineDb.addToSyncQueue(
            operationType: 'update_profile',
            tableName: 'profiles',
            data: {'user_id': userId, ...updates},
            recordId: userId,
            priority: 1,
          );
          
          return {
            'success': true,
            'offline': true,
            'message': 'Saved offline due to connection error.',
            'error': onlineError.toString(),
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to update profile',
      };
    }
  }
  
  Future<Map<String, dynamic>> syncAllPendingData() async {
    try {
      if (!(await _connectivity.isConnectionStable())) {
        return {
          'success': false,
          'message': 'No stable internet connection',
          'synced': 0,
        };
      }
      
      int syncedCount = 0;
      int failedCount = 0;
      
      final pendingListings = await _offlineDb.getPendingListings();
      for (final listing in pendingListings) {
        try {
          final listingData = Map<String, dynamic>.from(listing);
          
          listingData.remove('local_id');
          listingData.remove('sync_status');
          listingData.remove('sync_retry_count');
          listingData.remove('last_sync_attempt');
          listingData.remove('error_message');
          
          if (listingData['booked_slots'] is String) {
            listingData['booked_slots'] = jsonDecode(listingData['booked_slots']);
          }
          
          final device = _mapToDevice(listingData);
          await _listingService.createListing(device);
          
          await _offlineDb.updateListingSyncStatus(
            listing['local_id'] as int,
            'synced',
          );
          
          syncedCount++;
        } catch (e) {
          await _offlineDb.updateListingSyncStatus(
            listing['local_id'] as int,
            'failed',
            error: e.toString(),
          );
          failedCount++;
        }
      }
      
      final pendingProfileUpdates = await _offlineDb.getPendingProfileUpdates();
      final updatesByUser = <String, Map<String, dynamic>>{};
      
      for (final update in pendingProfileUpdates) {
        final userId = update['user_id'] as String;
        final fieldName = update['field_name'] as String;
        final newValue = update['new_value'] as String?;
        
        if (!updatesByUser.containsKey(userId)) {
          updatesByUser[userId] = {};
        }
        
        if (newValue != null) {
          updatesByUser[userId]![fieldName] = newValue;
        }
      }
      
      for (final entry in updatesByUser.entries) {
        final userId = entry.key;
        final updates = entry.value;
        
        if (updates.isEmpty) continue;
        
        try {
          if (updates.containsKey('full_name') || updates.containsKey('phone')) {
            await _supabase.auth.updateUser(
              UserAttributes(
                data: {
                  if (updates.containsKey('full_name')) 'full_name': updates['full_name'],
                  if (updates.containsKey('phone')) 'phone': updates['phone'],
                },
              ),
            );
          }
          
          await _supabase.from('profiles').update({
            ...updates,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('user_id', userId);
          
          for (final update in pendingProfileUpdates.where((u) => u['user_id'] == userId)) {
            await _offlineDb.updateProfileSyncStatus(update['id'] as int, 'synced');
          }
          
          syncedCount += updates.length;
        } catch (e) {
          for (final update in pendingProfileUpdates.where((u) => u['user_id'] == userId)) {
            await _offlineDb.updateProfileSyncStatus(
              update['id'] as int,
              'failed',
              error: e.toString(),
            );
          }
          failedCount += updates.length;
        }
      }
      
      await _offlineDb.deleteSyncedListings();
      await _offlineDb.deleteSyncedProfileUpdates();
      await _offlineDb.deleteSyncedOperations();
      
      return {
        'success': true,
        'message': 'Sync completed. Synced: $syncedCount, Failed: $failedCount',
        'synced': syncedCount,
        'failed': failedCount,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Sync failed',
        'synced': 0,
        'failed': 0,
      };
    }
  }
  
  Future<int> getPendingItemsCount() async {
    return await _offlineDb.getPendingItemsCount();
  }
  
  Future<void> cleanupOldData() async {
    await _offlineDb.cleanupOldData();
  }
}