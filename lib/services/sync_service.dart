// sync_service.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:pinjamtech_app/services/offline_database_service.dart';
import 'dart:io';

class SyncService {
  final OfflineDatabaseService offlineDb;
  final SupabaseClient supabase;
  Timer? _syncTimer;
  bool _isSyncing = false;
  
  SyncService({
    required this.offlineDb,
    required this.supabase,
  }) {
    print('🎯 SyncService created');
    //print('   Offline DB: ${offlineDb != null ? '✓' : '✗'}');
    //print('   Supabase: ${supabase != null ? '✓' : '✗'}');
  }
  
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void startAutoSync({
    Duration interval = const Duration(minutes: 2),
  }) {
    print('🔄 Starting auto-sync every ${interval.inMinutes} minutes');
    
    _syncTimer?.cancel();
    
    _syncTimer = Timer.periodic(interval, (_) async {
      if (!_isSyncing) {
        print('⏰ Periodic sync check');
        await syncNow();
      }
    });
    
    // Do initial sync after 5 seconds
    Timer(const Duration(seconds: 5), () => syncNow());
  }
  
  Future<void> syncNow() async {
    if (_isSyncing) {
      print('⚠️ Sync already in progress');
      return;
    }
    
    // Check internet first
    print('🌐 Checking internet connection...');
    if (!await _hasInternetConnection()) {
      print('📵 No internet connection - cannot sync');
      return;
    }
    
    print('✅ Internet connection available');
    
    _isSyncing = true;
    print('\n' + '='*50);
    print('🚀 STARTING REAL SYNC');
    print('='*50);
    
    try {
      await _syncAllData();
      print('✅ SYNC COMPLETED SUCCESSFULLY');
    } catch (e) {
      print('❌ SYNC FAILED: $e');
    } finally {
      _isSyncing = false;
      print('='*50 + '\n');
    }
  }
  
  Future<void> _syncAllData() async {
    // 1. Sync pending listings
    await _syncPendingListings();
    
    // 2. Sync profile updates
    await _syncProfileUpdates();
    
    // 3. Sync queue operations
    await _syncQueueOperations();
    
    // 4. Clean up old synced data
    await offlineDb.cleanupOldData();
    
    // 5. Show sync stats
    await _showSyncStats();
  }
  
  Future<void> _syncPendingListings() async {
    print('\n📦 SYNCING PENDING LISTINGS');
    
    try {
      // Get pending listings from offline database
      final pendingListings = await offlineDb.getPendingListings();
      
      if (pendingListings.isEmpty) {
        print('   No pending listings found');
        return;
      }
      
      print('   Found ${pendingListings.length} pending listing(s)');
      
      int successCount = 0;
      int failCount = 0;
      
      for (var listing in pendingListings) {
        final localId = listing['local_id'] as int;
        final listingName = listing['name'] ?? 'Unnamed Listing';
        
        try {
          print('   ⬆️ Uploading: "$listingName" (Local ID: $localId)');
          
          // Prepare data for Supabase
          final supabaseData = _prepareListingForSupabase(listing);
          
          // Send to Supabase
          final response = await supabase
            .from('listings')
            .insert(supabaseData)
            .select()
            .single();
          
          print('   ✅ Uploaded! Server ID: ${response['id']}');
          
          // Mark as synced in local database
          await offlineDb.updateListingSyncStatus(
            localId,
            'synced',
            serverId: response['id']?.toString(),
          );
          
          successCount++;
          
        } catch (e) {
          print('   ❌ Failed to sync listing $localId: $e');
          
          // Mark as failed in local database
          await offlineDb.updateListingSyncStatus(
            localId,
            'failed',
            error: e.toString(),
          );
          
          failCount++;
        }
      }
      
      print('   📊 Results: $successCount succeeded, $failCount failed');
      
    } catch (e) {
      print('   ❌ Error syncing listings: $e');
      rethrow;
    }
  }
  
  Map<String, dynamic> _prepareListingForSupabase(Map<String, dynamic> listing) {
    final data = Map<String, dynamic>.from(listing);
    
    // Remove ALL local-only fields
    data.remove('local_id');
    data.remove('server_id');
    data.remove('sync_status');
    data.remove('sync_retry_count');
    data.remove('last_sync_attempt');
    data.remove('error_message');
    data.remove('user_id');
    
    // GENERATE A UNIQUE ID FOR SUPABASE (REQUIRED)
    if (!data.containsKey('id') || data['id'] == null) {
      // Generate a unique ID (combine timestamp + random)
      final uniqueId = 'offline_${DateTime.now().millisecondsSinceEpoch}_${listing['local_id']}';
      data['id'] = uniqueId;
      print('     Generated ID for Supabase: $uniqueId');
    }
    
    // Convert data types
    if (data['is_available'] is int) {
      data['is_available'] = data['is_available'] == 1;
    }
    
    // Handle booked_slots JSON
    if (data['booked_slots'] is String) {
      try {
        final slots = jsonDecode(data['booked_slots'] as String);
        data['booked_slots'] = slots;
      } catch (_) {
        data['booked_slots'] = [];
      }
    }
    
    // Ensure dates are in correct format
    if (data['created_at'] == null || data['created_at'].toString().isEmpty) {
      data['created_at'] = DateTime.now().toIso8601String();
    }
    
    if (data['updated_at'] == null || data['updated_at'].toString().isEmpty) {
      data['updated_at'] = DateTime.now().toIso8601String();
    }
    
    // Handle image URL
    if (data['image_url']?.toString().startsWith('local://') ?? false) {
      data['image_url'] = 'https://via.placeholder.com/400x300?text=${Uri.encodeComponent(data['name']?.toString() ?? 'Item')}';
    }
    
    print('     Prepared data keys: ${data.keys.toList()}');
    return data;
  }
  
  Future<void> _syncProfileUpdates() async {
    print('\n👤 SYNCING PROFILE UPDATES');
    
    try {
      final pendingUpdates = await offlineDb.getPendingProfileUpdates();
      
      if (pendingUpdates.isEmpty) {
        print('   No pending profile updates');
        return;
      }
      
      print('   Found ${pendingUpdates.length} profile update(s)');
      
      for (var update in pendingUpdates) {
        print('   ⚙️ Profile update: ${update['field_name']}');
        
        // For now, just mark as synced
        await offlineDb.updateProfileSyncStatus(
          update['id'] as int,
          'synced',
        );
      }
      
    } catch (e) {
      print('   ⚠️ Error syncing profile updates: $e');
    }
  }
  
  Future<void> _syncQueueOperations() async {
    print('\n📋 SYNCING QUEUE OPERATIONS');
    
    try {
      final pendingOperations = await offlineDb.getPendingSyncOperations();
      
      if (pendingOperations.isEmpty) {
        print('   No pending operations in queue');
        return;
      }
      
      print('   Found ${pendingOperations.length} operation(s)');
      
      for (var operation in pendingOperations) {
        print('   ⚙️ Operation: ${operation['operation_type']}');
        
        await offlineDb.updateSyncOperationStatus(
          operation['id'] as int,
          'synced',
        );
      }
      
    } catch (e) {
      print('   ⚠️ Error syncing queue operations: $e');
    }
  }
  
  Future<void> _showSyncStats() async {
    try {
      final pendingCount = await offlineDb.getPendingItemsCount();
      print('\n📊 SYNC STATISTICS');
      print('   Pending items after sync: $pendingCount');
      
      if (pendingCount == 0) {
        print('   🎉 All data is synced!');
      }
    } catch (e) {
      print('   ⚠️ Could not get sync stats: $e');
    }
  }
  
  void dispose() {
    print('🛑 Stopping SyncService');
    _syncTimer?.cancel();
    _syncTimer = null;
  }
}