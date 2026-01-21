// lib/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  // Initialize AwesomeNotifications (call this in main.dart)
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // Use default app icon
      [
        NotificationChannel(
          channelKey: 'pinjamtech_channel',
          channelName: 'PinjamTech Notifications',
          channelDescription: 'Notifications for bookings and updates',
          defaultColor: Colors.blue,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        )
      ],
    );

    // Request notification permissions
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  // Android-style notification (slides from top, like system notifications)
  static void showAndroidStyleNotification(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.notifications,
    Duration displayDuration = const Duration(seconds: 4),
    VoidCallback? onTap,
    bool playSound = true,
    bool vibrate = true,
  }) {
    // Get the OverlayState
    final overlay = Overlay.of(context);
    
    // Create overlay entry
    OverlayEntry? overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _AndroidNotificationWidget(
        title: title,
        message: message,
        icon: icon,
        playSound: playSound,
        vibrate: vibrate,
        onTap: () {
          overlayEntry?.remove();
          onTap?.call();
        },
        onDismiss: () {
          overlayEntry?.remove();
        },
      ),
    );

    // Insert the overlay
    overlay.insert(overlayEntry);

    // Auto remove after duration
    Future.delayed(displayDuration, () {
      if (overlayEntry?.mounted == true) {
        overlayEntry?.remove();
      }
    });
  }

  // Booking-specific notification
  static void showBookingNotification(
    BuildContext context,
    String title,
    String message,
    String bookingId, {
    VoidCallback? onTap,
  }) {
    showAndroidStyleNotification(
      context,
      title: title,
      message: message,
      icon: Icons.calendar_today,
      onTap: onTap ?? () {
        print('Navigate to booking: $bookingId');
      },
    );
  }

  // General notification
  static void showNotification(
    BuildContext context,
    String title,
    String message, {
    IconData icon = Icons.notifications,
    VoidCallback? onTap,
  }) {
    showAndroidStyleNotification(
      context,
      title: title,
      message: message,
      icon: icon,
      onTap: onTap,
    );
  }

  // Message notification
  static void showMessageNotification(
    BuildContext context,
    String sender,
    String message,
  ) {
    showAndroidStyleNotification(
      context,
      title: sender,
      message: message,
      icon: Icons.message,
      onTap: () {
        print('Navigate to chat with $sender');
      },
    );
  }
}

// Android-style notification widget
class _AndroidNotificationWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final bool playSound;
  final bool vibrate;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _AndroidNotificationWidget({
    required this.title,
    required this.message,
    required this.icon,
    required this.playSound,
    required this.vibrate,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_AndroidNotificationWidget> createState() => _AndroidNotificationWidgetState();
}

class _AndroidNotificationWidgetState extends State<_AndroidNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Play sound and vibrate using AwesomeNotifications
    if (widget.playSound || widget.vibrate) {
      _playNotificationFeedback();
    }
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  Future<void> _playNotificationFeedback() async {
    try {
      // Create a silent notification just for sound/vibration feedback
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'pinjamtech_channel',
          title: '', // Silent notification
          body: '',
          wakeUpScreen: false,
          fullScreenIntent: false,
          autoDismissible: true,
          displayOnForeground: false,
          displayOnBackground: false,
        ),
      );
    } catch (e) {
      print('Error playing notification feedback: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismissNotification() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 8,
      right: 8,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: widget.onTap,
            onHorizontalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dx.abs() > 300) {
                _dismissNotification();
              }
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                'PinjamTech',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'now',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}