import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSender;
  final String time;
  final String senderName;
  final bool isOffer;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isSender,
    required this.time,
    required this.senderName,
    this.isOffer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // Name label
        Padding(
          padding: isSender 
            ? const EdgeInsets.only(right: 12, bottom: 2)
            : const EdgeInsets.only(left: 12, bottom: 2),
          child: Text(
            senderName,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Bubble
        Align(
          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOffer 
                  ? Colors.blue.shade50.withOpacity(0.8)
                  : (isSender 
                    ? Colors.blue.shade50 
                    : Colors.grey.shade100),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isSender 
                    ? const Radius.circular(16) 
                    : const Radius.circular(4),
                  bottomRight: isSender 
                    ? const Radius.circular(4) 
                    : const Radius.circular(16),
                ),
                border: Border.all(
                  color: isOffer 
                    ? Colors.blue.shade200
                    : (isSender 
                      ? Colors.blue.shade100 
                      : Colors.grey.shade300),
                  width: isOffer ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isOffer)
                    Row(
                      children: [
                        Icon(
                          Icons.local_offer,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "OFFER",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  if (isOffer) const SizedBox(height: 8),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade900,
                      fontWeight: isOffer ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}