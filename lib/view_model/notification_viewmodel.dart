// lib/view_models/notification_view_model.dart
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import '../services/notification_service.dart'; // ADD THIS IMPORT
import 'package:flutter/material.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository;
  
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  NotificationViewModel(this._repository);

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // SINGLE initialize method with context (for SMS/WhatsApp style popups)
  Future<void> initialize({
    required String userId,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get initial unread count
      _unreadCount = await _repository.getUnreadCount(userId);
      
      // Subscribe to realtime stream for popups
      _repository.getNotificationsStream(userId).listen((newNotifications) {
        // Check if new notification arrived
        if (_notifications.isNotEmpty && newNotifications.isNotEmpty) {
          final latestNotification = newNotifications.first;
          
          // Check if this is a brand new notification
          final isBrandNew = !_notifications.any((n) => 
            n.id == latestNotification.id
          );
          
          if (isBrandNew) {
            // Show SMS/WhatsApp style popup
            _showNewNotificationPopup(context, latestNotification);
          }
        }
        
        // Update UI
        _notifications = newNotifications;
        _unreadCount = newNotifications.where((n) => !n.isRead).length;
        notifyListeners();
      });
      
      _error = null;
    } catch (e) {
      _error = 'Failed to load notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _showNewNotificationPopup(
    BuildContext context,
    NotificationModel notification,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (notification.type.contains('booking')) {
        NotificationService.showBookingNotification(
          context,
          notification.title,
          notification.body,
          notification.orderId ?? notification.id,
          onTap: () {
            // Navigate to booking details
            print('Navigate to booking: ${notification.orderId}');
          },
        );
      } else if (notification.type.contains('message')) {
        NotificationService.showMessageNotification(
          context,
          notification.title,
          notification.body,
        );
      } else {
        NotificationService.showNotification(
          context,
          notification.title,
          notification.body,
          icon: Icons.notifications,
          onTap: () {
            // Navigate to notification details
            print('Notification tapped: ${notification.id}');
          },
        );
      }
    });
  }

  // Keep your existing methods
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
    } catch (e) {
      _error = 'Failed to mark as read: $e';
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _repository.markAllAsRead(userId);
    } catch (e) {
      _error = 'Failed to mark all as read: $e';
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
    } catch (e) {
      _error = 'Failed to delete notification: $e';
      notifyListeners();
    }
  }
}