// models/message_model.dart
class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String content;
  final String type; // 'text', 'offer', 'attachment', 'voice'
  final DateTime sentAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = 'text',
    required this.sentAt,
    this.isRead = false,
    this.metadata,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'text',
      sentAt: DateTime.parse(json['sent_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'type': type,
      'sent_at': sentAt.toIso8601String(),
      'is_read': isRead,
      'metadata': metadata,
    };
  }

  bool get isOffer => type == 'offer';
  String get formattedTime {
    final hour = sentAt.hour % 12 == 0 ? 12 : sentAt.hour % 12;
    final period = sentAt.hour < 12 ? 'AM' : 'PM';
    return "$hour:${sentAt.minute.toString().padLeft(2, '0')} $period";
  }
}