import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_bubble.dart';
import 'rentee_quick_replies.dart';
import 'message_input.dart';
import 'package:pinjamtech_app/view/profile/view_renter_profile.dart'; 

class RenterChatScreen extends StatefulWidget {
  final String chatName;
  final String itemName;
  final String itemPrice;
  final String initialInquiry;
  final String? userId;
  
  const RenterChatScreen({
    super.key,
    required this.chatName,
    required this.itemName,
    required this.itemPrice,
    required this.initialInquiry,
    this.userId,
  });

  @override
  State<RenterChatScreen> createState() => _RenterChatScreenState();
}

class _RenterChatScreenState extends State<RenterChatScreen> {
  // Colors from your design system
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color background = Color(0xFFF5F5F5);

  late List<Map<String, dynamic>> messages;
  final TextEditingController _controller = TextEditingController();
  Set<int> usedQuickReplies = {}; // Track which quick replies have been used

  @override
  void initState() {
    super.initState();
    
    // Initialize with the initial inquiry from the borrower
    messages = [
      {
        "fromMe": false, // Borrower sent this
        "text": widget.initialInquiry,
        "time": "10:30 AM",
        "senderName": widget.chatName,
      },
    ];
  }

  void sendMessage(String text) {
    if (text.isEmpty) return;

    setState(() {
      messages.add({
        "fromMe": true, // Lender (Renter) sending
        "text": text,
        "time": _formatTime(DateTime.now()),
        "senderName": "You",
      });
    });

    _controller.clear();
  }

  void sendQuickReply(String text, int index) {
    sendMessage(text);
    setState(() {
      usedQuickReplies.add(index); // Mark this quick reply as used
    });
  }

  void sendVoiceMessage() {
    setState(() {
      messages.add({
        "fromMe": true,
        "text": "🎤 Voice message",
        "time": _formatTime(DateTime.now()),
        "senderName": "You",
      });
    });
  }

  void sendAttachment(String type) {
    setState(() {
      messages.add({
        "fromMe": true,
        "text": "📎 [$type attachment]",
        "time": _formatTime(DateTime.now()),
        "senderName": "You",
      });
    });
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    return "$hour:${time.minute.toString().padLeft(2, '0')} $period";
  }

  void markAsRented() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Mark as Rented",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "Are you sure you want to mark this item as rented?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                color: textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Item marked as rented",
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: primaryGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
            ),
            child: Text(
              "Confirm",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to show the renter profile popup
  void _showRenterProfile() {
    // Create a dummy Renter object for demonstration
    final renter = Renter(
      id: widget.userId ?? '1',
      fullName: widget.chatName,
      profilePhotoUrl: '', // Empty for avatar fallback
      bio: 'A responsible renter with good rental history.',
      occupation: 'Student',
      age: 25,
      languages: ['English', 'Malay', 'Mandarin'],
      joinedDate: DateTime.now().subtract(const Duration(days: 365)),
      rating: 4.8,
      totalReviews: 15,
      rentalHistory: [
        'Rented MacBook Air for 7 days',
        'Rented Camera for 3 days',
        'Rented Drone for 5 days',
      ],
      phoneNumber: '+60123456789',
    );

    showDialog(
      context: context,
      builder: (context) => RenterProfilePopup(user: renter),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 1,
        title: Text(
          widget.chatName,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: markAsRented,
            icon: Icon(Icons.check_circle_outline, color: Colors.white),
            tooltip: "Mark as Rented",
          ),
        ],
      ),
      body: Column(
        children: [
          // Item Details Section (Lender's item being inquired about)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.itemName,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Available",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryGreen.withOpacity(0.3)),
                      ),
                      child: Text(
                        widget.itemPrice,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                
                // User info (Borrower who is inquiring) - NOW CLICKABLE
                GestureDetector(
                  onTap: _showRenterProfile,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryBlue.withOpacity(0.4)),
                        ),
                        child: Center(
                          child: Text(
                            widget.chatName.substring(0, 1),
                            style: GoogleFonts.poppins(
                              color: primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.chatName,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: primaryBlue,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Renter",
                              style: GoogleFonts.poppins(
                                color: textLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Text(
                          "Inquiry",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.orange[700]!,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Messages List
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 60,
                          color: textLight.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No messages yet",
                          style: GoogleFonts.poppins(
                            color: textLight,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return ChatBubble(
                        text: msg["text"] as String,
                        isSender: msg["fromMe"] as bool,
                        time: msg["time"] as String,
                        senderName: msg["senderName"] as String,
                      );
                    },
                  ),
          ),
          
          // Quick Replies Section 
          RenterQuickReplies(
            onReplySelected: sendQuickReply,
            itemPrice: widget.itemPrice,
            usedReplies: usedQuickReplies,
          ),
          
          // Message Input
          MessageInput(
            controller: _controller,
            onSendMessage: sendMessage,
            onSendVoiceMessage: sendVoiceMessage,
            onSendAttachment: sendAttachment,
          ),
        ],
      ),
    );
  }
}