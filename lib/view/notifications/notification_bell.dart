// lib/view/notifications/notification_bell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/notification_viewmodel.dart'; // Corrected path

class NotificationBell extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;

  const NotificationBell({
    Key? key,
    required this.onPressed,
    this.size = 28,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<NotificationViewModel>(context);
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, size: size),
          onPressed: onPressed,
        ),
        if (viewModel.unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                viewModel.unreadCount > 9 
                  ? '9+' 
                  : viewModel.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}