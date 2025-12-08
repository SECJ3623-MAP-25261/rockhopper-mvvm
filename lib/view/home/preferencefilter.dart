import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this
import '../profile/edit_profile.dart';
import '../home/home_roles/choose_rolescreen.dart';

class PreferenceFilteredScreen extends StatelessWidget {
  // Consistent colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Celebration icon
Icon(
  Icons.celebration,
  size: 100,
  color: primaryGreen,
),

const SizedBox(height: 20),

Text(
  "Preferences Saved!",
  style: GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: primaryGreen,
  ),
),
              // Main message
              Text(
                "That's cool! Now we will filter\nyour preferences onto your timeline!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // Sub message
              Text(
                "Your timeline will be updated accordingly\nwhen you rent or list items.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: textLight,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 50),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // "Can I go now?" button - Goes to role selection
                  SizedBox(
                    width: 150,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChooseRoleScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Color(0xFF2196F3)),
                      ),
                      child: Text(
                        "Choose Role",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                  ),

                  // "I want to update profile" button
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfile(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        "Update Profile",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Hint text
              Text(
                "Choose a role first to get started",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: textLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}