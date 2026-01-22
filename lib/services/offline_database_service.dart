import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class OfflineDatabaseService {
  static final OfflineDatabaseService _instance = OfflineDatabaseService._internal();
  factory OfflineDatabaseService() => _instance;
  OfflineDatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'pinjamtech_offline.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pending_listings(
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id TEXT,
        name TEXT NOT NULL,
        brand TEXT,
        price_per_day REAL NOT NULL,
        deposit REAL,
        category TEXT,
        condition TEXT,
        is_available INTEGER DEFAULT 1,
        max_rental_days INTEGER DEFAULT 30,
        description TEXT,
        specifications TEXT,
        location TEXT,
        image_url TEXT,
        booked_slots TEXT DEFAULT '[]',
        user_id TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        sync_status TEXT DEFAULT 'pending',
        sync_retry_count INTEGER DEFAULT 0,
        last_sync_attempt TEXT,
        error_message TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE pending_profile_updates(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        field_name TEXT NOT NULL,
        old_value TEXT,
        new_value TEXT,
        sync_status TEXT DEFAULT 'pending',
        sync_retry_count INTEGER DEFAULT 0,
        created_at TEXT,
        last_sync_attempt TEXT,
        error_message TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation_type TEXT NOT NULL,
        table_name TEXT NOT NULL,
        record_id TEXT,
        data TEXT NOT NULL,
        sync_status TEXT DEFAULT 'pending',
        sync_retry_count INTEGER DEFAULT 0,
        created_at TEXT,
        last_sync_attempt TEXT,
        priority INTEGER DEFAULT 0
      )
    ''');

    await db.execute('CREATE INDEX idx_pending_listings_sync ON pending_listings(sync_status)');
    await db.execute('CREATE INDEX idx_pending_profile_sync ON pending_profile_updates(sync_status)');
    await db.execute('CREATE INDEX idx_sync_queue_status ON sync_queue(sync_status, priority)');
  }

  Future<int> savePendingListing(Map<String, dynamic> listing) async {
  final db = await database;
  
  // Convert booked_slots to JSON string if it's a List
  if (listing['booked_slots'] is List) {
    listing['booked_slots'] = jsonEncode(listing['booked_slots']);
  }
  
  // Convert boolean to int (SQLite doesn't support boolean)
  if (listing['is_available'] is bool) {
    listing['is_available'] = (listing['is_available'] as bool) ? 1 : 0;
  }
  
  final now = DateTime.now().toIso8601String();
  listing['created_at'] = now;
  listing['updated_at'] = now;
  
  // Debug print
  print('💾 Saving to offline database:');
  listing.forEach((key, value) {
    print('   $key: $value (${value.runtimeType})');
  });
  
  return await db.insert('pending_listings', listing);
}

  Future<List<Map<String, dynamic>>> getPendingListings() async {
    final db = await database;
    return await db.query(
      'pending_listings',
      where: "sync_status IN ('pending', 'failed')",
      orderBy: 'created_at ASC',
    );
  }

  Future<void> updateListingSyncStatus(int localId, String status, {String? serverId, String? error}) async {
  final db = await database;
  final updates = <String, dynamic>{  
    'sync_status': status,
    'last_sync_attempt': DateTime.now().toIso8601String(),  
  };
  
  if (serverId != null) updates['server_id'] = serverId;
  if (error != null) updates['error_message'] = error;
  
  if (status == 'failed') {
    final record = await db.query(
      'pending_listings',
      columns: ['sync_retry_count'],  
      where: 'local_id = ?',
      whereArgs: [localId],  
    );
    
    if (record.isNotEmpty) {
      final retryCount = record.first['sync_retry_count'] as int;
      updates['sync_retry_count'] = retryCount + 1;  
    }
  }
  
  await db.update(
    'pending_listings',
    updates,
    where: 'local_id = ?',
    whereArgs: [localId],  
  );
}
  Future<void> deleteSyncedListings() async {
    final db = await database;
    await db.delete('pending_listings', where: "sync_status = 'synced'");
  }

  Future<int> savePendingProfileUpdate({
    required String userId,
    required String fieldName,
    required dynamic newValue,
    dynamic oldValue,
  }) async {
    final db = await database;
    
    final data = {
      'user_id': userId,
      'field_name': fieldName,
      'old_value': oldValue?.toString(),
      'new_value': newValue.toString(),
      'created_at': DateTime.now().toIso8601String(),
      'sync_status': 'pending',
    };
    
    return await db.insert('pending_profile_updates', data);
  }

  Future<List<Map<String, dynamic>>> getPendingProfileUpdates() async {
    final db = await database;
    return await db.query(
      'pending_profile_updates',
      where: "sync_status IN ('pending', 'failed')",
      orderBy: 'created_at ASC',
    );
  }

  Future<void> updateProfileSyncStatus(int id, String status, {String? error}) async {
    final db = await database;
    final updates = {
      'sync_status': status,
      'last_sync_attempt': DateTime.now().toIso8601String(),
    };
    
    if (error != null) updates['error_message'] = error;
    
    if (status == 'failed') {
      final record = await db.query(
        'pending_profile_updates',
        columns: ['sync_retry_count'],
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (record.isNotEmpty) {
        final retryCount = record.first['sync_retry_count'] as int;
        updates['sync_retry_count'] = (retryCount + 1).toString();  
      }
    }
    
    await db.update('pending_profile_updates', updates, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteSyncedProfileUpdates() async {
    final db = await database;
    await db.delete('pending_profile_updates', where: "sync_status = 'synced'");
  }

  Future<int> addToSyncQueue({
    required String operationType,
    required String tableName,
    required Map<String, dynamic> data,
    String? recordId,
    int priority = 0,
  }) async {
    final db = await database;
    
    final queueItem = {
      'operation_type': operationType,
      'table_name': tableName,
      'record_id': recordId,
      'data': jsonEncode(data),
      'sync_status': 'pending',
      'priority': priority,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    return await db.insert('sync_queue', queueItem);
  }

  Future<List<Map<String, dynamic>>> getPendingSyncOperations() async {
    final db = await database;
    return await db.query(
      'sync_queue',
      where: "sync_status IN ('pending', 'failed')",
      orderBy: 'priority DESC, created_at ASC',
    );
  }

  Future<void> updateSyncOperationStatus(int id, String status, {String? error}) async {
    final db = await database;
    final updates = {
      'sync_status': status,
      'last_sync_attempt': DateTime.now().toIso8601String(),
    };
    
    if (error != null) updates['error_message'] = error;
    
    if (status == 'failed') {
      final record = await db.query(
        'sync_queue',
        columns: ['sync_retry_count'],
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (record.isNotEmpty) {
        final retryCount = record.first['sync_retry_count'] as int;
        updates['sync_retry_count'] = (retryCount + 1).toString();  
      }
    }
    
    await db.update('sync_queue', updates, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteSyncedOperations() async {
    final db = await database;
    await db.delete('sync_queue', where: "sync_status = 'synced'");
  }

  Future<int> getPendingItemsCount() async {
    final db = await database;
    
    final listings = Sqflite.firstIntValue(await db.rawQuery(
      "SELECT COUNT(*) FROM pending_listings WHERE sync_status IN ('pending', 'failed')"
    )) ?? 0;
    
    final profiles = Sqflite.firstIntValue(await db.rawQuery(
      "SELECT COUNT(*) FROM pending_profile_updates WHERE sync_status IN ('pending', 'failed')"
    )) ?? 0;
    
    final queue = Sqflite.firstIntValue(await db.rawQuery(
      "SELECT COUNT(*) FROM sync_queue WHERE sync_status IN ('pending', 'failed')"
    )) ?? 0;
    
    return listings + profiles + queue;
  }

  Future<void> cleanupOldData() async {
    final db = await database;
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30)).toIso8601String();
    
    await db.delete(
      'pending_listings',
      where: "sync_status = 'synced' AND created_at < ?",
      whereArgs: [thirtyDaysAgo],
    );
    
    await db.delete(
      'pending_profile_updates',
      where: "sync_status = 'synced' AND created_at < ?",
      whereArgs: [thirtyDaysAgo],
    );
    
    await db.delete(
      'sync_queue',
      where: "sync_status = 'synced' AND created_at < ?",
      whereArgs: [thirtyDaysAgo],
    );
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
