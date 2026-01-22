// lib/view/home/rentee.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Add this
import 'package:pinjamtech_app/view_model/rentee_main_viewmodel.dart';
import '../../view_model/notification_viewmodel.dart'; // Add this
import '../home/home_roles/rentee_home.dart';
import '../profile/rentee_profile.dart';
import '../listings/createlist.dart';
import '../updates/notifications_screen.dart'; // Add this
import '../home/renter.dart';
import '../home/home_roles/role_navbar.dart';

class RenteeMainView extends StatelessWidget {
  const RenteeMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RenteeMainViewModel(),
      child: const _RenteeMainUI(),
    );
  }
}

class _RenteeMainUI extends StatelessWidget {
  const _RenteeMainUI();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RenteeMainViewModel>();
    final notificationVM = context.watch<NotificationViewModel>();

    // Initialize notifications when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
          // PASS CONTEXT for SMS/WhatsApp style popups
      notificationVM.initialize(
        userId: user.id,
        context: context, // Add this!
      );
        
      }
    });

    final pages = [
      const RenteeHome(),
      const CreateList(),
      const NotificationsScreen(cartItems: []), // Add notifications page
      const RenteeProfile(),
    ];

    return Scaffold(
      body: pages[vm.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: vm.currentIndex,
        onTap: vm.changeTab,
        // onRoleSwitch: _switchToRentee,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: "Home"
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add), 
            label: "Create"
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
            label: "Profile"
          ),
        ],
      ),
    );
  }
}