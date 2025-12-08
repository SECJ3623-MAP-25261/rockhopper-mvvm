// models/chat_model.dart
class Chat {
  final String id;
  final String? itemId;
  final String renterId;
  final String renteeId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int unreadCount;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, dynamic>? itemData;
  final Map<String, dynamic>? renterData;
  final Map<String, dynamic>? renteeData;

  Chat({
    required this.id,
    this.itemId,
    required this.renterId,
    required this.renteeId,
    required this.createdAt,
    required this.updatedAt,
    this.unreadCount = 0,
    this.lastMessage,
    this.lastMessageAt,
    this.itemData,
    this.renterData,
    this.renteeData,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      itemId: json['item_id'] as String?,
      renterId: json['renter_id'] as String,
      renteeId: json['rentee_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      unreadCount: json['unread_count'] as int? ?? 0,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      itemData: json['item'] as Map<String, dynamic>?,
      renterData: json['renter'] as Map<String, dynamic>?,
      renteeData: json['rentee'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'renter_id': renterId,
      'rentee_id': renteeId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'unread_count': unreadCount,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt?.toIso8601String(),
    };
  }

  // Helper to check if current user is renter or rentee
  bool isRenter(String currentUserId) => renterId == currentUserId;
  bool isRentee(String currentUserId) => renteeId == currentUserId;

  // Get the other user's ID
  String getOtherUserId(String currentUserId) {
    return currentUserId == renterId ? renteeId : renterId;
  }

  // Get other user's name
  String? getOtherUserName(String currentUserId) {
    if (currentUserId == renterId) {
      return renteeData?['full_name'] ?? renteeData?['username'];
    } else {
      return renterData?['full_name'] ?? renterData?['username'];
    }
  }
}