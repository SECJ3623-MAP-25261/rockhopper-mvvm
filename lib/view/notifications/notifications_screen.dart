// lib/view/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/notification_viewmodel.dart'; // Corrected path

class NotificationsScreen extends StatelessWidget {
  final String userId;

  const NotificationsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<NotificationViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (viewModel.unreadCount > 0)
            TextButton(
              onPressed: () => viewModel.markAllAsRead(userId),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _buildBody(viewModel),
    );
  }

  Widget _buildBody(NotificationViewModel viewModel) {
    if (viewModel.isLoading && viewModel.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(child: Text('Error: ${viewModel.error}'));
    }

    if (viewModel.notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.notifications.length,
      itemBuilder: (context, index) {
        final notification = viewModel.notifications[index];
        return ListTile(
          leading: _getIcon(notification.type),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Text(notification.body),
          trailing: Text(
            _formatTime(notification.createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          tileColor: notification.isRead ? null : Colors.blue[50],
          onTap: () {
            viewModel.markAsRead(notification.id);
            // Handle notification tap
          },
        );
      },
    );
  }

  Icon _getIcon(String type) {
    if (type.contains('booking')) {
      return const Icon(Icons.calendar_today, color: Colors.green);
    } else if (type.contains('reminder')) {
      return const Icon(Icons.alarm, color: Colors.orange);
    }
    return const Icon(Icons.notifications, color: Colors.blue);
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}