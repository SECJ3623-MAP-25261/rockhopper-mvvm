// screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Add this
import '../../models/cart_item.dart';
import '../../models/notification_model.dart';
import '../../view_model/notification_viewmodel.dart'; // Add this


class NotificationsScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const NotificationsScreen({
    super.key,
    required this.cartItems,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color background = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    // Initialize notifications from Supabase
    _initializeNotifications();
  }

  void _initializeNotifications() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notificationVM = context.read<NotificationViewModel>();

         // USE NAMED PARAMETERS with context
      notificationVM.initialize(
        userId: user.id,
        context: context, // Add this!
      );
        
      });
    }
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 30) {
      final months = difference.inDays ~/ 30;
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  void _markAllAsRead(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final notificationVM = context.read<NotificationViewModel>();
      notificationVM.markAllAsRead(user.id);
    }
  }

  void _showCartItemDetails(BuildContext context, String cartItemId) {
    final cartItem = widget.cartItems.firstWhere(
      (item) => item.id == cartItemId,
      orElse: () => CartItem(
        id: 'unknown',
        name: 'Unknown Item',
        price: 0,
        image: '',
        description: '',
        condition: '',
        category: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        brand: '',
        maxRentalDays: 0,
        location: '',
      ),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cart Item Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundImage: NetworkImage(cartItem.image),
                radius: 30,
              ),
              title: Text(
                cartItem.name,
                style: GoogleFonts.poppins(),
              ),
              subtitle: Text(
                'RM ${cartItem.price.toStringAsFixed(2)}/day',
                style: GoogleFonts.poppins(),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Rental Period', 
                '${cartItem.startDate.day}/${cartItem.startDate.month} - ${cartItem.endDate.day}/${cartItem.endDate.month}'),
            _buildDetailRow('Total Days', '${cartItem.rentalDays} days'),
            _buildDetailRow('Total Price', 'RM ${cartItem.totalPrice.toStringAsFixed(2)}'),
            _buildDetailRow('Condition', cartItem.condition),
            _buildDetailRow('Category', cartItem.category),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                color: textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to cart screen
              // Navigator.pushNamed(context, '/renting-cart');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
            ),
            child: Text(
              'View in Cart',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: textLight,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      )
    );
  }

  IconData _getIconForType(String type) {
    if (type.contains('booking')) {
      return Icons.calendar_today;
    } else if (type.contains('reminder')) {
      return Icons.alarm;
    } else if (type.contains('pickup')) {
      return Icons.airport_shuttle;
    } else if (type.contains('return')) {
      return Icons.keyboard_return;
    }
    return Icons.notifications;
  }

  Color _getColorForType(String type) {
    if (type.contains('booking')) {
      return Colors.green;
    } else if (type.contains('reminder')) {
      return Colors.orange;
    } else if (type.contains('pickup')) {
      return Colors.blue;
    } else if (type.contains('return')) {
      return Colors.red;
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationViewModel>(
      builder: (context, notificationVM, child) {
        final notifications = notificationVM.notifications;
        
        return Scaffold(
          backgroundColor: background,
          appBar: AppBar(
            title: Text(
              'Notifications',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            actions: [
              if (notificationVM.unreadCount > 0)
                IconButton(
                  icon: const Icon(Icons.mark_email_read),
                  onPressed: () => _markAllAsRead(context),
                  tooltip: 'Mark all as read',
                ),
            ],
          ),
          body: notificationVM.isLoading && notifications.isEmpty
              ? _buildLoadingState()
              : notifications.isEmpty
                  ? _buildEmptyState()
                  : _buildNotificationsList(context, notificationVM),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No notifications',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Add items to your cart to receive notifications about your rentals',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
      BuildContext context, NotificationViewModel notificationVM) {
    final notifications = notificationVM.notifications;

    return Column(
      children: [
        // Unread count header
        if (notificationVM.unreadCount > 0)
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryBlue.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.notifications_active, color: primaryBlue),
                const SizedBox(width: 8),
                Text(
                  '${notificationVM.unreadCount} unread notification${notificationVM.unreadCount > 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: primaryBlue,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _markAllAsRead(context),
                  child: Text(
                    'Mark all as read',
                    style: GoogleFonts.poppins(
                      color: primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Notifications list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              final user = Supabase.instance.client.auth.currentUser;
              if (user != null) {
                await notificationVM.initialize(
                   userId: user.id,
                   context: context);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(context, notification, index, notificationVM);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(
      BuildContext context,
      NotificationModel notification,
      int index,
      NotificationViewModel notificationVM) {
    
    final isUnread = !notification.isRead;
    final icon = _getIconForType(notification.type);
    final color = _getColorForType(notification.type);
    final timeAgo = _getTimeAgo(notification.createdAt);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        notificationVM.deleteNotification(notification.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
          border: isUnread 
              ? Border.all(color: primaryBlue.withOpacity(0.3), width: 1.5)
              : null,
        ),
        child: ListTile(
          onTap: () {
            notificationVM.markAsRead(notification.id);
            // Handle notification tap based on data
            if (notification.data?['action'] == 'view_booking') {
              // Navigate to booking details
            }
          },
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                        color: textDark,
                      ),
                    ),
                  ),
                  if (isUnread)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                notification.body,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: textLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  timeAgo,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: textLight,
                  ),
                ),
                const Spacer(),
                // Show booking badge if related to booking
                if (notification.orderId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.book_online, size: 12, color: primaryBlue),
                        const SizedBox(width: 4),
                        Text(
                          'Booking',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Show total price if available in data
                if (notification.data?['total_price'] != null)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'RM${notification.data!['total_price']}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Trailing action button
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 20, color: textLight),
            onSelected: (value) {
              if (value == 'mark_read') {
                notificationVM.markAsRead(notification.id);
              } else if (value == 'delete') {
                notificationVM.deleteNotification(notification.id);
              }
            },
            itemBuilder: (context) => [
              if (isUnread)
                PopupMenuItem<String>(
                  value: 'mark_read',
                  child: ListTile(
                    leading: Icon(Icons.check_circle, size: 20, color: primaryBlue),
                    title: Text(
                      'Mark as read',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ),
              PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: const Icon(Icons.delete, size: 20, color: Colors.red),
                  title: Text(
                    'Delete',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}