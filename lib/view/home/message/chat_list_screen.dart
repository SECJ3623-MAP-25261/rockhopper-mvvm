import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_screen.dart';
import 'package:pinjamtech_app/services/chat_repository.dart';
import 'package:pinjamtech_app/services/chat_helper.dart';
import 'package:pinjamtech_app/view/profile/view_rentee_profile.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color background = Color(0xFFF5F5F5);

  final ChatRepository _chatRepo = ChatRepository();
  List<Map<String, dynamic>> chats = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final dbChats = await _chatRepo.getUserChats();
      
      // Convert to UI format
      final uiChats = dbChats.map((chat) {
        return ChatHelper.chatToUIMap(chat, _chatRepo.currentUserId);
      }).toList();

      setState(() {
        chats = uiChats;
        isLoading = false;
        errorMessage = null;
      });
    } catch (error) {
      print('Error loading chats: $error');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load chats. Please try again.';
      });
    }
  }

  void _refreshChats() {
    setState(() {
      isLoading = true;
    });
    _loadChats();
  }

  void _markAsRead(int index) {
    setState(() {
      chats[index]["unread"] = 0;
    });
  }

  void _showRenteeProfile(BuildContext context, Map<String, dynamic> chat) {
    // This would need to be updated based on your actual Rentee model
    // For now, showing a simple placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Profile"),
        content: Text("Profile for ${chat['username']}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  // Get the correct user ID based on role
  String _getOtherUserId(Map<String, dynamic> chat) {
    return chat['otherUserId'] as String? ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          "My Inquiries",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 1,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshChats,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          color: Colors.white,
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryBlue),
            SizedBox(height: 16),
            Text(
              "Loading chats...",
              style: GoogleFonts.poppins(color: textLight),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 60),
            SizedBox(height: 16),
            Text(
              errorMessage!,
              style: GoogleFonts.poppins(color: textLight),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshChats,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
              ),
              child: Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: textLight.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              "No chats yet",
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Start a conversation by inquiring about an item",
              style: GoogleFonts.poppins(
                color: textLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to home or listings screen
                // Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
              ),
              child: Text("Browse Items"),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: chats.length,
      separatorBuilder: (context, index) => Divider(
        height: 0,
        color: Colors.grey.shade200,
      ),
      itemBuilder: (_, i) {
        final chat = chats[i];
        
        final String item = chat["listingName"] as String;
        final String username = chat["username"] as String;
        final String time = chat["time"] as String;
        final String lastMessage = chat["lastMessage"] as String;
        final String itemPrice = chat["itemPrice"] as String;
        final int unread = chat["unread"] as int;
        final String chatId = chat["chatId"] as String;
        final String listingId = chat["listingId"] as String;
        final String otherUserId = _getOtherUserId(chat);
        
        return InkWell(
          onTap: () {
            _markAsRead(i);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  chatId: chatId, // NEW: Pass chat ID
                  chatName: username,
                  itemName: item,
                  itemPrice: itemPrice,
                  initialInquiry: "Hi, I'm interested in renting your $item. Is it available?",
                  userId: otherUserId,
                  otherUserId: otherUserId, // NEW: Pass other user ID
                ),
              ),
            );
          },
          onLongPress: () {
            _showRenteeProfile(context, chat);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getRandomAvatarColor(username),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      username.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unread > 0)
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: primaryBlue,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryBlue.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  unread.toString(),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "Rentee (Owner)",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              username,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: textLight,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 12,
                              color: textLight,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                lastMessage,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: textLight,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Right side: Only Time and Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Time
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        time,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        itemPrice,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRandomAvatarColor(String username) {
    final List<Color> colors = [
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.red.shade700,
      Colors.purple.shade700,
      Colors.teal.shade700,
      Colors.pink.shade700,
      Colors.indigo.shade700,
      Colors.cyan.shade700,
      Colors.lime.shade700,
    ];
    
    int hash = username.hashCode.abs();
    return colors[hash % colors.length];
  }
}