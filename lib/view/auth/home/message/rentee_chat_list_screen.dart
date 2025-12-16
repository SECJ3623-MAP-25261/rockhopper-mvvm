import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'rentee_chat_screen.dart';

class RenterChatListScreen extends StatefulWidget {
  const RenterChatListScreen({super.key});

  @override
  State<RenterChatListScreen> createState() => _RenterChatListScreenState();
}

class _RenterChatListScreenState extends State<RenterChatListScreen> {
  // Colors from your design system
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color background = Color(0xFFF5F5F5);

  List<Map<String, dynamic>> chats = [
    {
      "item": "MacBook Air M4 2024",
      "username": "Anonym123",
      "time": "13:13",
      "inquiry": "Is this still available?",
      "itemPrice": "RM 17/day",
      "unread": 2,
    },
    {
      "item": "ASUS ROG Zephyrus G14",
      "username": "JohnDoe",
      "time": "11:34",
      "inquiry": "Can we negotiate the price?",
      "itemPrice": "RM 25/day",
      "unread": 0,
    },
    {
      "item": "Canon M50 Camera",
      "username": "JaneSmith",
      "time": "10:43",
      "inquiry": "Where can we meet?",
      "itemPrice": "RM 15/day",
      "unread": 1,
    },
    {
      "item": "iPhone 15 Pro",
      "username": "MikeChen",
      "time": "08:17",
      "inquiry": "Any scratches?",
      "itemPrice": "RM 12/day",
      "unread": 0,
    },
  ];

  void _markAsRead(int index) {
    setState(() {
      chats[index]["unread"] = 0; // Clear unread count
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          "Inquiries",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          color: Colors.white,
        ),
        child: ListView.separated(
          itemCount: chats.length,
          separatorBuilder: (context, index) => Divider(
            height: 0,
            color: Colors.grey.shade200,
          ),
          itemBuilder: (_, i) {
            final chat = chats[i];
            
            final String item = chat["item"] as String;
            final String username = chat["username"] as String;
            final String time = chat["time"] as String;
            final String inquiry = chat["inquiry"] as String;
            final String itemPrice = chat["itemPrice"] as String;
            final int unread = chat["unread"] as int;
            
            return InkWell(
              onTap: () {
                _markAsRead(i); // Clear unread count before navigation
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RenterChatScreen(
                      chatName: username,
                      itemName: item,
                      itemPrice: itemPrice,
                      initialInquiry: inquiry,
                    ),
                  ),
                );
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
                    //after click on avatar, it will shows ViewRenteeProfile
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _getAvatarColor(username).withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getAvatarColor(username).withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          username.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: _getAvatarColor(username),
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
                          Text(
                            username,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: textLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: primaryGreen.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.question_answer,
                                  size: 12,
                                  color: primaryGreen,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    inquiry,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: primaryGreen,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
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
                    
                    // Price & Time
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
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
                            time,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            itemPrice,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: primaryGreen,
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
        ),
      ),
    );
  }

  Color _getAvatarColor(String username) {
    final colors = [
      primaryGreen,
      primaryBlue,
      Colors.orange.shade700,
      Colors.purple.shade700,
    ];
    
    String cleanUsername = username.split(' ').first;
    return colors[cleanUsername.hashCode % colors.length];
  }
}