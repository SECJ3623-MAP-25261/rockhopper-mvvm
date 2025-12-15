import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinjamtech_app/view_model/rentee_viewmodel.dart';
import '../home/home_roles/rentee_home.dart';
import '../profile/rentee_profile.dart';
import '../listings/createlist.dart';
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

    final pages = const [
      RenteeHomeView(),
      CreateList(),
      RenteeProfile(),
    ];

    return Scaffold(
      body: pages[vm.currentIndex],
      bottomNavigationBar: CustomBottomNav(
        currentIndex: vm.currentIndex,
        onTap: vm.changeTab,
        currentRole: "rentee",
        onRoleSwitch: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RenterMain()),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Create"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
