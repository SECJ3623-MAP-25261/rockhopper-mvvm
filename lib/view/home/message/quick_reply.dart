import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RenterQuickReplies extends StatelessWidget {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color background = Color(0xFFF5F5F5);

  final Function(String, int) onReplySelected;
  final String itemPrice;
  final bool isRenter; // To differentiate between renter/borrower and rentee/lender

  const RenterQuickReplies({
    super.key,
    required this.onReplySelected,
    required this.itemPrice,
    this.isRenter = true, // Default to true for Renter/Borrower
  });

  @override
  Widget build(BuildContext context) {
    // Different replies for Renter (Borrower) vs Rentee (Lender)
    final List<String> replies = isRenter 
        ? [
            // RENTER/BORROWER replies
            "Can we negotiate the price?",
            "I'd like to rent it for 3 days",
            "Where can we meet to check the item?",
            "Can I see more photos?",
            "Is there a security deposit?",
            "What's included in the rental?",
            "Can you deliver?",
            "Are there any additional fees?",
          ]
        : [
            // RENTEE/LENDER replies (from your original file)
            "Yes, it's available!",
            "The price is $itemPrice",
            "We can meet at KLCC or Mid Valley",
            "No defects, it's in perfect condition",
            "I require a security deposit of RM 100",
            "Available for pickup tomorrow",
            "Price is negotiable for longer rentals",
            "Comes with original accessories",
          ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.05),
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: primaryBlue,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isRenter ? "Quick questions as a borrower" : "Quick answers for renters",
                style: GoogleFonts.poppins(
                  color: primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Horizontal scrollable list - ALL replies always available
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: replies.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(
                    right: index < replies.length - 1 ? 8 : 0,
                  ),
                  child: ElevatedButton(
                    onPressed: () => onReplySelected(replies[index], index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: primaryBlue.withOpacity(0.3),
                        ),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      replies[index],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}