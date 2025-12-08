
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pinjamtech_app/models/message_model.dart';

class ChatRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user ID
  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  // ============ CHAT OPERATIONS ============

  // Get all chats for current user
  Future<List<Map<String, dynamic>>> getUserChats() async {
    final response = await _supabase
        .from('chats')
        .select('''
          *,
          listing:listings(*),
          renter:profiles!chats_renter_id_fkey(user_id, full_name, avatar_url),
          rentee:profiles!chats_rentee_id_fkey(user_id, full_name, avatar_url)
        ''')
        .or('renter_id.eq.$currentUserId,rentee_id.eq.$currentUserId')
        .order('updated_at', ascending: false);

    return response as List<Map<String, dynamic>>;
  }

  // Get or create a chat
  Future<Map<String, dynamic>> getOrCreateChat({
    required String listingId,
    required String renterId,
    required String renteeId,
  }) async {
    // Check if chat exists
    final existingChat = await _supabase
        .from('chats')
        .select()
        .eq('listing_id', listingId)
        .eq('renter_id', renterId)
        .eq('rentee_id', renteeId)
        .maybeSingle();

    if (existingChat != null) {
      return existingChat as Map<String, dynamic>;
    }

    // Create new chat
    final newChat = await _supabase
        .from('chats')
        .insert({
          'listing_id': listingId,
          'renter_id': renterId,
          'rentee_id': renteeId,
        })
        .select()
        .single();

    return newChat as Map<String, dynamic>;
  }

  // ============ MESSAGE OPERATIONS ============

  // Get messages for a chat
  Future<List<Message>> getMessages(String chatId, {int limit = 50}) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('sent_at', ascending: true)
        .limit(limit);

    final messages = (response as List)
        .map((json) => Message.fromJson(json))
        .toList();

    return messages;
  }

  // Send a text message
  Future<Message> sendTextMessage({
    required String chatId,
    required String receiverId,
    required String content,
  }) async {
    final response = await _supabase
        .from('messages')
        .insert({
          'chat_id': chatId,
          'sender_id': currentUserId,
          'receiver_id': receiverId,
          'content': content,
          'type': 'text',
        })
        .select()
        .single();

    // The trigger will automatically update the chat's last_message
    return Message.fromJson(response as Map<String, dynamic>);
  }

  // Send an offer message
  Future<Message> sendOfferMessage({
    required String chatId,
    required String receiverId,
    required String content,
    required double price,
    required int days,
  }) async {
    final response = await _supabase
        .from('messages')
        .insert({
          'chat_id': chatId,
          'sender_id': currentUserId,
          'receiver_id': receiverId,
          'content': content,
          'type': 'offer',
          'metadata': {
            'price': price,
            'days': days,
            'total': price * days,
            'status': 'pending',
          },
        })
        .select()
        .single();

    return Message.fromJson(response as Map<String, dynamic>);
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('chat_id', chatId)
        .eq('receiver_id', currentUserId)
        .eq('is_read', false);
  }

  // Get unread count for a chat
    Future<int> getUnreadCount(String chatId) async {
      final response = await _supabase
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .eq('receiver_id', currentUserId)
        .eq('is_read', false);

      return response.length;
    }

  // Get chat by ID with listing details
  Future<Map<String, dynamic>?> getChatWithDetails(String chatId) async {
    final response = await _supabase
        .from('chats')
        .select('''
          *,
          listing:listings(*),
          renter:profiles!chats_renter_id_fkey(user_id, full_name, avatar_url),
          rentee:profiles!chats_rentee_id_fkey(user_id, full_name, avatar_url)
        ''')
        .eq('id', chatId)
        .maybeSingle();

    return response as Map<String, dynamic>?;
  }
}