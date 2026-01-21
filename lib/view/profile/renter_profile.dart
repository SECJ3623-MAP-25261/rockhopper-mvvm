import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/profile_model.dart';
import 'renter_chart.dart';
import '../../view/settings/settings.dart';

class RenterProfile extends StatefulWidget {
  const RenterProfile({super.key});

  @override
  State<RenterProfile> createState() => _RenterProfileState();
}

class _RenterProfileState extends State<RenterProfile> {
  // Colors from your design system
  static const Color primaryBlue = Color(0xFF2196F3);
  //static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color background = Color(0xFFF5F5F5);

  late final ProfileModel user;

  @override
  void initState() {
    super.initState();
    user = ProfileModel(
      id: '1',
      firstName: 'Jaafar',
      lastName: 'Baba',
      username: 'siti',
      roles: 'renter',
      email: 'jaafar@example.com',
      gender: 'Male',
      phone: '0123456789',
      bio: 'Tech enthusiast and laptop lover!',
      avatarUrl: null,
      rating: 4.7,
      totalRentals: 24,
      isOwnProfile: true,
      followersCount: 0,
      followingCount: 0,
      joinDate: DateTime(2023, 3, 15),
      recentOrders: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
             _goToSettings();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  iconColor: primaryBlue,
                  title: 'Notifications',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '0',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.history,
                  iconColor: primaryBlue,
                  title: 'Rental History',
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.edit_outlined,
                  iconColor: primaryBlue,
                  title: 'Update Profile',
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.location_on_outlined,
                  iconColor: primaryBlue,
                  title: 'Renter Activity Insight',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RenterChartScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.language,
                  iconColor: primaryBlue,
                  title: 'Language',
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.logout,
                  iconColor: Colors.red,
                  title: 'Log Out',
                  onTap: _showLogoutDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(0.9),
            primaryBlue.withOpacity(0.7),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username ?? 'User',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.bio ?? 'Tech enthusiast',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Following',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '#${user.followingCount}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Followers',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${user.followersCount}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rating',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 18,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.rating?.toStringAsFixed(1) ?? '4.7',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
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
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textDark,
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: textLight,
            ),
        onTap: onTap,
      ),
    );
  }

 void _goToSettings() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SettingsPage()),
  );
}


  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Log Out',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Add logout logic here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}