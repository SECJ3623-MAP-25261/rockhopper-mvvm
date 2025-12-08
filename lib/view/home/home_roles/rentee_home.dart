// Rentee_home.dart (with dummy data for testing)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this import
import '../message/rentee_chat_list_screen.dart';
import 'package:pinjamtech_app/models/device_model.dart';
import '../../listings/edit_listing.dart';
import '../../listings/delete_listing.dart';
import '../../listings/createlist.dart';
import '../search_screen.dart';
import 'package:pinjamtech_app/view/profile/rentee_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RenteeHome extends StatefulWidget {
  const RenteeHome({super.key});

  @override
  State<RenteeHome> createState() => _RenteeHomeState();
}

class _RenteeHomeState extends State<RenteeHome> {
  // Colors for rentee (green theme)
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color greenDark = Color(0xFF388E3C);
  static const Color greenLight = Color(0xFFC8E6C9);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
   
  final SupabaseClient supabase = Supabase.instance.client;

  //LIST DEVICES 
  List<Device> devices = [];
  bool isLoading = true;
  
    @override
  void initState() {
    super.initState();
    fetchDevices();
  }
   //FETCH FROM CREATE LIST using user_id
   Future<void> fetchDevices() async {
    setState(() {
      isLoading = true;
    });

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await supabase
        .from('listings')
        .select()
        .eq('user_id', userId);

    final List<Device> fetchedDevices = [];
    
     for (final item in response as List<dynamic>) {
      fetchedDevices.add(Device(
        id: item['id'],
        name: item['name'],
        brand: item['brand'] ?? '',
        pricePerDay: (item['price_per_day'] ?? 0).toDouble(),
        imageUrl: item['image_url'] ?? '',
        isAvailable: item['is_available'] ?? true,
        maxRentalDays: item['max_rental_days'] ?? 0,
        condition: item['condition'] ?? '',
        description: item['description'] ?? '',
        category: item['category'] ?? '',
        bookedSlots: (item['booked_slots'] as List<dynamic>?)
                ?.map((e) => DateTime.parse(e))
                .toList() ??
            [],
        deposit: (item['deposit'] as num?)?.toDouble(),
      ));
    }

    setState(() {
      devices = fetchedDevices;
      isLoading = false;
    });
  }

  void _deleteDevice(Device device) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final res = await supabase
        .from('listings')
        .delete()
        .eq('id', device.id)
        .eq('user_id', userId);

    if (res != null) {
      setState(() {
        devices.removeWhere((d) => d.id == device.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateList(),
            ),
          ).then((newDevice) {
            if (newDevice != null && newDevice is Device) {
              setState(() {
                devices.add(newDevice);// add new listing to grid 
              });
              fetchDevices(); // fetch latest from Supabase

            }
          });
        },
        backgroundColor: primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
        : ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // PinjamTech Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pinjam',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: primaryGreen,
                  ),
                ),
                Text(
                  'Tech',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black, // Tech in black for contrast
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _buildUserInfo(context),

            const SizedBox(height: 20),
            
            // Search Bar
            _buildSearchBar(context),
            const SizedBox(height: 20),

            // Dashboard Title
            Text(
              "Rentee Dashboard",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: primaryGreen,
              ),
            ),

            const SizedBox(height: 20),
            Text(
              "My Active Rentals",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return _buildGridDeviceCard(devices[index]);
              },
            ),

            const SizedBox(height: 30),
            Text(
              "Quick Actions",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _quickActionCircle(Icons.search, "Browse", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                }),
                _quickActionCircle(Icons.sell, "My Listing", () {}),
                _quickActionCircle(Icons.history, "History", () {}),
                _quickActionCircle(Icons.settings, "Settings", () {}),
              ],
            ),

            const SizedBox(height: 30),
            Text(
              "Recent Activity",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            const SizedBox(height: 15),

            _activityItem("Rented MacBook Pro", "2 days ago"),
            _activityItem("Returned iPhone 15", "1 week ago"),
            _activityItem("Rented PS5", "2 weeks ago"),
          ],
        ),
      ),
    );
  }

  // Search Bar Method
  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: IgnorePointer(
          child: TextField(
            style: GoogleFonts.poppins(),
            decoration: InputDecoration(
              hintText: "Search Device",
              hintStyle: GoogleFonts.poppins(color: textLight),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: primaryGreen),
              suffixIcon: Icon(Icons.filter_list, color: primaryGreen),
            ),
          ),
        ),
      ),
    );
  }

  // Device Card
  Widget _buildGridDeviceCard(Device device) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditListing(
              device: device,
              bookedSlots: device.bookedSlots,
            ),
          ),
        ).then((updatedDevice) {
          if (updatedDevice != null && updatedDevice is Device) {
            setState(() {
              final index = devices.indexWhere((d) => d.id == device.id);
              if (index != -1) {
                devices[index] = updatedDevice;
              }
            });
          }
        });
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => _buildDeleteBottomSheet(device),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: Image.network(
                device.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: Icon(Icons.device_unknown, size: 50, color: primaryGreen),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAME & BRAND
                  Text(
                    device.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: textDark,
                    ),
                  ),
                  if (device.brand.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      device.brand,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: textLight,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 6),
                  
                  // PRICE
                  Text(
                    "RM ${device.pricePerDay.toStringAsFixed(2)}/day",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  // DEPOSIT (if exists)
                  if (device.deposit != null && device.deposit! > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Deposit: RM ${device.deposit!.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 6),
                  
                  // STATUS & CATEGORY
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: device.isAvailable ? primaryGreen : Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            device.isAvailable ? "Available" : "Not Available",
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: greenLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          device.category,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: greenDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

  // Delete Bottom Sheet
  Widget _buildDeleteBottomSheet(Device device) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Listing Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.edit, color: primaryGreen),
            title: Text(
              'Edit Listing',
              style: GoogleFonts.poppins(),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditListing(
                    device: device,
                    bookedSlots: device.bookedSlots,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: Text(
              'Delete Listing',
              style: GoogleFonts.poppins(),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeleteListing(
                    device: device,
                  ),
                ),
              ).then((shouldDelete) {
                if (shouldDelete == true) {
                  setState(() {
                    devices.removeWhere((d) => d.id == device.id);
                  });
                }
              });
            },
          ),
          const SizedBox(height: 16),
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
        ],
      ),
    );
  }

  // User Info
  Widget _buildUserInfo(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello!",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: textLight,
            ),
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              Text(
                "Jaafar",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: greenLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryGreen.withOpacity(0.3)),
                ),
                child: Text(
                  'Rentee',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: greenDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      subtitle: Text(
        "Manage your rental items",
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: textLight,
        ),
      ),

      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RenterChatListScreen()),
              );
            },
            child: Container(
              height: 48,
              width: 48,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.grey[300],
              ),
              child: Icon(Icons.chat_bubble_outline, size: 26, color: primaryGreen),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RenteeProfile()),
              );
            },
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.grey[300],
              ),
              child: Icon(Icons.person, size: 30, color: primaryGreen),
            ),
          )
        ],
      ),
    );
  }

  // Quick Action Circle
  Widget _quickActionCircle(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryGreen, width: 2),
              color: greenLight,
            ),
            child: Icon(icon, color: primaryGreen, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Activity Item
  Widget _activityItem(String title, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.history, color: primaryGreen),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}