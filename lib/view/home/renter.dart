// lib/view/home/renter.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Add this
import '../../view_model/notification_viewmodel.dart'; // Add this
import '../home/home_roles/role_switch_bottom_sheet.dart';
import '../home/home_roles/renter_home.dart';
import '../home/home_roles/rentee_home.dart';
import '../cart/renting_cart.dart';
import '../profile/renter_profile.dart';
import '../home/home_roles/role_navbar.dart';
import '../updates/notifications_screen.dart';
import '../home/rentee.dart';

class RenterMain extends StatefulWidget {
  const RenterMain({super.key});

  @override
  State<RenterMain> createState() => _RenterMainState();
}

class _RenterMainState extends State<RenterMain> {
  int currentIndex = 0;

  final pages = const [
    RenterHomeView(),
    CartScreen(),
    NotificationsScreen(cartItems: []),
    RenterProfile(),
  ];

  void _switchToRentee() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const RenteeHome(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize notifications when screen loads
    _initializeNotifications();
  }

  void _initializeNotifications() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notificationVM = context.read<NotificationViewModel>();

          // PASS CONTEXT for SMS/WhatsApp style popups
      notificationVM.initialize(
        userId: user.id,
        context: context, // Add this!
      );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: Consumer<NotificationViewModel>(
        builder: (context, notificationVM, child) {
          // Custom bottom nav with notification badge
          return BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (i) => setState(() => currentIndex = i),
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.add_shopping_cart),
                label: "Cart",
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications),
                    if (notificationVM.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            notificationVM.unreadCount > 9 
                              ? '9+' 
                              : notificationVM.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: "Updates",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          );
        },
      ),
    );
  }
}