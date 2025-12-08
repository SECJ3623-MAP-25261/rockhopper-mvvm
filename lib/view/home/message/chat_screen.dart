import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_bubble.dart';
import 'quick_reply.dart';
import 'message_input.dart';
import 'make_offer_system.dart';
import 'package:pinjamtech_app/services/chat_repository.dart';
import 'package:pinjamtech_app/services/chat_helper.dart';
import 'package:pinjamtech_app/view/profile/view_rentee_profile.dart';
import 'package:pinjamtech_app/models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String chatId; // NEW: Chat ID from database
  final String chatName;
  final String itemName;
  final String itemPrice;
  final String initialInquiry;
  final String? userId;
  final String? otherUserId; // NEW: ID of the person you're chatting with

  const ChatScreen({
    super.key,
    required this.chatId, // NEW: Make it required
    required this.chatName,
    required this.itemName,
    required this.itemPrice,
    required this.initialInquiry,
    this.userId,
    this.otherUserId, // NEW: Add this parameter
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color background = Color(0xFFF5F5F5);

  final ChatRepository _chatRepo = ChatRepository();
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _offerPriceController = TextEditingController();
  final TextEditingController _offerDaysController = TextEditingController();
  Set<int> usedQuickReplies = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _offerDaysController.text = "3";
  }

  Future<void> _loadMessages() async {
    try {
      final List<Message> dbMessages = await _chatRepo.getMessages(widget.chatId);
      
      // Convert to UI format
      final uiMessages = dbMessages.map((msg) {
        return ChatHelper.messageToUIMap(
          msg,
          _chatRepo.currentUserId,
          widget.chatName,
        );
      }).toList();

      // If no messages, add the initial inquiry
      if (uiMessages.isEmpty && widget.initialInquiry.isNotEmpty) {
        uiMessages.add({
          "fromMe": true,
          "text": widget.initialInquiry,
          "time": _formatTime(DateTime.now()),
          "senderName": "You (Borrower)",
        });
      }

      setState(() {
        messages = uiMessages;
        isLoading = false;
      });

      // Mark messages as read
      await _chatRepo.markMessagesAsRead(widget.chatId);
    } catch (error) {
      print('Error loading messages: $error');
      // Fall back to dummy data if database fails
      _loadDummyMessages();
      setState(() => isLoading = false);
    }
  }

  void _loadDummyMessages() {
    // Fallback to your original dummy data
    setState(() {
      messages = [
        {
          "fromMe": true,
          "text": widget.initialInquiry,
          "time": "10:30 AM",
          "senderName": "You (Borrower)",
        },
        {
          "fromMe": false,
          "text": "Hi! Yes, my ${widget.itemName} is available. The price is ${widget.itemPrice}. How many days would you like to rent it for?",
          "time": "10:32 AM",
          "senderName": widget.chatName,
        },
        {
          "fromMe": true,
          "text": "I'd like to rent it for 3 days. Can we meet tomorrow to check the item?",
          "time": "10:35 AM",
          "senderName": "You (Borrower)",
        },
        {
          "fromMe": false,
          "text": "Sure! I'm available after 2 PM tomorrow. The item is in perfect condition. Would you like to make an official offer?",
          "time": "10:37 AM",
          "senderName": widget.chatName,
        },
      ];
    });
  }

  @override
  void dispose() {
    _offerPriceController.dispose();
    _offerDaysController.dispose();
    super.dispose();
  }

  void _showRenteeProfile() {
    final rentee = Rentee(
      id: widget.userId ?? '1',
      fullName: widget.chatName,
      profilePhotoUrl: '',
      isVerified: true,
      bio: 'Professional equipment owner with excellent reviews. All items are well-maintained and come with original accessories.',
      rating: 4.9,
      totalReviews: 42,
      responseTime: 'Within 1 hour',
      location: 'Kuala Lumpur',
      availableRooms: ['Meeting Room', 'Co-working Space'],
      houseRules: [
        'No smoking near equipment',
        'Handle with care',
        'Return in original condition',
        'Late returns incur additional charges',
      ],
      joinedDate: DateTime.now().subtract(const Duration(days: 365)),
      phoneNumber: '+60123456789',
    );

    showDialog(
      context: context,
      builder: (context) => ViewRenteeProfile(user: rentee),
    );
  }

  void sendMessage(String text) async {
    if (text.isEmpty || widget.otherUserId == null) {
      // Fallback to local state if no database connection
      _sendLocalMessage(text);
      return;
    }

    try {
      // Send to database
      await _chatRepo.sendTextMessage(
        chatId: widget.chatId,
        receiverId: widget.otherUserId!,
        content: text,
      );

      // Update UI immediately
      setState(() {
        messages.add({
          "fromMe": true,
          "text": text,
          "time": _formatTime(DateTime.now()),
          "senderName": "You (Borrower)",
        });
      });

      _controller.clear();
    } catch (error) {
      print('Error sending message: $error');
      // Fallback to local state
      _sendLocalMessage(text);
    }
  }

  void _sendLocalMessage(String text) {
    if (text.isEmpty) return;

    setState(() {
      messages.add({
        "fromMe": true,
        "text": text,
        "time": _formatTime(DateTime.now()),
        "senderName": "You (Borrower)",
      });
    });

    _controller.clear();
  }

  void sendQuickReply(String text, int index) {
    sendMessage(text);
    setState(() {
      usedQuickReplies.add(index);
    });
  }

  void sendVoiceMessage() {
    // TODO: Implement voice message upload to Supabase Storage
    setState(() {
      messages.add({
        "fromMe": true,
        "text": "🎤 Voice message",
        "time": _formatTime(DateTime.now()),
        "senderName": "You (Borrower)",
      });
    });
  }

  void sendAttachment(String type) {
    // TODO: Implement attachment upload to Supabase Storage
    setState(() {
      messages.add({
        "fromMe": true,
        "text": "📎 [$type attachment]",
        "time": _formatTime(DateTime.now()),
        "senderName": "You (Borrower)",
      });
    });
  }

  void sendOfferMessage(String price, String days) async {
    if (widget.otherUserId == null) {
      // Fallback to local state
      _sendLocalOfferMessage(price, days);
      return;
    }

    try {
      final offerContent = ChatHelper.formatOfferMessage(
        widget.itemName,
        price,
        days,
      );

      // Send to database
      await _chatRepo.sendOfferMessage(
        chatId: widget.chatId,
        receiverId: widget.otherUserId!,
        content: offerContent,
        price: double.parse(price),
        days: int.parse(days),
      );

      // Update UI
      setState(() {
        messages.add({
          "fromMe": true,
          "text": offerContent,
          "time": _formatTime(DateTime.now()),
          "senderName": "You (Borrower)",
          "isOffer": true,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Rental offer sent for $days day${days == "1" ? "" : "s"} at RM $price/day"),
          backgroundColor: primaryBlue,
        ),
      );
    } catch (error) {
      print('Error sending offer: $error');
      // Fallback to local state
      _sendLocalOfferMessage(price, days);
    }
  }

  void _sendLocalOfferMessage(String price, String days) {
    String offerMessage = "📋 **Rental Offer:**\n";
    offerMessage += "• Item: ${widget.itemName}\n";
    offerMessage += "• Price: RM $price/day\n";
    offerMessage += "• Duration: $days day${days == "1" ? "" : "s"}\n";
    double total = double.parse(price) * int.parse(days);
    offerMessage += "• Total: RM ${total.toStringAsFixed(2)}\n";
    offerMessage += "• Status: Pending approval";
    
    setState(() {
      messages.add({
        "fromMe": true,
        "text": offerMessage,
        "time": _formatTime(DateTime.now()),
        "senderName": "You (Borrower)",
        "isOffer": true,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Rental offer sent for $days day${days == "1" ? "" : "s"} at RM $price/day"),
        backgroundColor: primaryBlue,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    return "$hour:${time.minute.toString().padLeft(2, '0')} $period";
  }

  void makeOffer() {
    String currentPrice = widget.itemPrice.replaceAll("RM ", "").replaceAll("/day", "").trim();
    _offerPriceController.text = currentPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OfferBottomSheet(
        itemName: widget.itemName,
        currentPrice: currentPrice,
        offerPriceController: _offerPriceController,
        offerDaysController: _offerDaysController,
        onSendOffer: (price, days) {
          Navigator.pop(context);
          sendOfferMessage(price, days);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String priceNumber = widget.itemPrice.replaceAll("RM ", "").replaceAll("/day", "");

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chatName,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              "Item Owner",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Item Details Section - Renter wants to rent this
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
                              "Available for Rent",
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
                        color: primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryBlue.withOpacity(0.3)),
                      ),
                      child: Text(
                        widget.itemPrice,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                
                // Price Details with Make Offer Button on the right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "RM $priceNumber",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        Text(
                          "Per day rental",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: textLight,
                          ),
                        ),
                      ],
                    ),
                    // Make Offer Button moved here (replacing "Flexible duration" text)
                    SizedBox(
                      width: 120, // Fixed width for the button
                      child: MakeOfferButton(
                        onPressed: makeOffer,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                
                // Item Owner Info - CLICKABLE
                GestureDetector(
                  onTap: _showRenteeProfile,
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
                            Row(
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 12,
                                  color: primaryGreen,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Verified Owner",
                                  style: GoogleFonts.poppins(
                                    color: primaryGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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
                          "Active",
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
            child: Container(
              decoration: BoxDecoration(
                color: background,
              ),
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: primaryBlue),
                          SizedBox(height: 16),
                          Text(
                            "Loading messages...",
                            style: GoogleFonts.poppins(color: textLight),
                          ),
                        ],
                      ),
                    )
                  : messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 60,
                                color: textLight.withOpacity(0.5),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "No messages yet",
                                style: GoogleFonts.poppins(
                                  color: textLight,
                                ),
                              ),
                              Text(
                                "Start the conversation",
                                style: GoogleFonts.poppins(
                                  color: textLight,
                                  fontSize: 12,
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
                            bool isOffer = msg["isOffer"] as bool? ?? false;

                            return ChatBubble(
                              text: msg["text"] as String,
                              isSender: msg["fromMe"] as bool,
                              time: msg["time"] as String,
                              senderName: msg["senderName"] as String,
                              isOffer: isOffer,
                            );
                          },
                        ),
            ),
          ),
          
          // Quick Replies Section - Customized for Renter/Borrower
          RenterQuickReplies(
            onReplySelected: sendQuickReply,
            itemPrice: widget.itemPrice,
            isRenter: true, 
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