import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../view/settings/settings.dart';
import '../updates/notifications_screen.dart';
import '../auth/welcome_screen.dart';
import 'edit_profile.dart';
import 'package:pinjamtech_app/view_model/renteeprofile_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'renteechart.dart';
import 'bookinghub.dart';


class RenteeProfile extends StatelessWidget {
  const RenteeProfile({super.key});

  // Theme colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color backgroundGrey = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RenteeProfileViewModel(),
      child: const _RenteeProfileUI(),
    );
  }
}

class _RenteeProfileUI extends StatelessWidget {
  const _RenteeProfileUI();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RenteeProfileViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (vm.hasError) {
      return Scaffold(
        backgroundColor: RenteeProfile.backgroundGrey,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 20),
              Text(
                'Failed to load profile',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: RenteeProfile.textDark),
              ),
              const SizedBox(height: 10),
              Text(
                vm.errorMessage,
                style: GoogleFonts.poppins(color: RenteeProfile.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: vm.loadProfile,
                child: Text('Retry', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ),
      );
    }

    final displayName = vm.getDisplayName();
    final email = vm.getEmail();
    final phone = vm.getPhone();
    final gender = vm.getGender();
    final bio = vm.getBio();
    final role = vm.getRole();
    final avatarUrl = vm.getAvatarUrl();
    final joinDate = vm.getJoinDate();
    //final rating = vm.getRating();

    return Scaffold(
      backgroundColor: RenteeProfile.backgroundGrey,
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: RenteeProfile.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ).then((_) => vm.loadProfile());
              }),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(displayName, email, role, joinDate, avatarUrl),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    iconColor: RenteeProfile.primaryGreen,
                    title: 'Notifications',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('0', style: GoogleFonts.poppins(fontSize: 14)),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => NotificationsScreen(cartItems: [])),
                      );
                    }),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.edit_outlined,
                  iconColor: RenteeProfile.primaryGreen,
                  title: 'Update Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditProfile()),
                    ).then((_) => vm.loadProfile());
                  },
                ),
                const SizedBox(height: 12),
                  _buildMenuItem(
                  icon: Icons.description,
                  iconColor: RenteeProfile.primaryGreen,
                  title: 'Booking hub',
                  subtitle: bio,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookingHub(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.description,
                  iconColor: RenteeProfile.primaryGreen,
                  title: 'Rentee Activity Insight',
                  subtitle: bio,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RenteeChartScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.logout,
                  iconColor: Colors.red,
                  title: 'Log Out',
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String displayName, String email, String role, DateTime joinDate, String? avatarUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      color: RenteeProfile.primaryGreen,
      child: Row(
        children: [
         CircleAvatar(
  radius: 40,
  backgroundColor: Colors.grey[300],
  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
      ? NetworkImage('$avatarUrl?cacheBust=${DateTime.now().millisecondsSinceEpoch}')
      : null,
  child: avatarUrl == null || avatarUrl.isEmpty
      ? const Icon(Icons.person, size: 40, color: Colors.white)
      : null,
)
,
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName,
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: role == 'rentee' ? Colors.white24 : Colors.white30,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(role.toUpperCase(),
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 8),
                Text(email,
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.9))),
                const SizedBox(height: 4),
                Text('Member since ${joinDate.year}',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 24),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: RenteeProfile.textDark)),
        subtitle: subtitle != null
            ? Text(subtitle, style: GoogleFonts.poppins(fontSize: 13, color: RenteeProfile.textLight))
            : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Out', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to log out?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: RenteeProfile.textLight))),
          TextButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WelcomeScreen()));
            },
            child: Text('Log Out', style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
