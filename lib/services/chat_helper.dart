// services/chat_helper.dart
import '../models/message_model.dart';

class ChatHelper {
  // Convert database message to UI format
  static Map<String, dynamic> messageToUIMap(
    Message message,
    String currentUserId,
    String otherUserName,
  ) {
    final isSender = message.senderId == currentUserId;
    
    return {
      'fromMe': isSender,
      'text': message.content,
      'time': message.formattedTime,
      'senderName': isSender ? 'You' : otherUserName,
      'isOffer': message.type == 'offer',
    };
  }

  // Convert database chat to UI format for list screen
  static Map<String, dynamic> chatToUIMap(
    Map<String, dynamic> chat,
    String currentUserId,
  ) {
    final isRenter = chat['renter_id'] == currentUserId;
    final otherUser = isRenter 
        ? chat['rentee'] as Map<String, dynamic>?
        : chat['renter'] as Map<String, dynamic>?;
    final listing = chat['listing'] as Map<String, dynamic>?;
    
    final otherUserId = isRenter ? chat['rentee_id'] : chat['renter_id'];
    final otherUserName = otherUser?['full_name'] ?? 'Unknown User';
    
    return {
      'chatId': chat['id'],
      'listingId': chat['listing_id'],
      'listingName': listing?['name'] ?? 'Unknown Listing',
      'username': otherUserName,
      'otherUserId': otherUserId,
      'time': _formatTime(chat['last_message_at']),
      'lastMessage': chat['last_message'] ?? 'New chat',
      'itemPrice': 'RM ${listing?['price_per_day']?.toStringAsFixed(2)}/day',
      'unread': chat['unread_count'] ?? 0,
      'listingImage': listing?['image_url'],
      'listingData': listing,
    };
  }

  static String _formatTime(dynamic time) {
    if (time == null) return 'Just now';
    
    try {
      final date = time is String ? DateTime.parse(time) : time as DateTime;
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      }
      return 'Just now';
    } catch (e) {
      return 'Just now';
    }
  }

  // Format offer message
  static String formatOfferMessage(
    String listingName,
    String price,
    String days,
  ) {
    double total = double.parse(price) * int.parse(days);
    
    return "📋 **Rental Offer:**\n"
           "• Item: $listingName\n"
           "• Price: RM $price/day\n"
           "• Duration: $days day${days == "1" ? "" : "s"}\n"
           "• Total: RM ${total.toStringAsFixed(2)}\n"
           "• Status: Pending approval";
  }
}