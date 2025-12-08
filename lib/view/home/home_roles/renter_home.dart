import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/device_model.dart';
import '../message/chat_list_screen.dart';
import '../search_screen.dart';
import  '../../listings/devicelistdetails.dart';

class RenterHome extends StatefulWidget {
  const RenterHome({super.key});

  @override
  State<RenterHome> createState() => _RenterHomeState();
}

class _RenterHomeState extends State<RenterHome> {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color blueLight = Color(0xFFE3F2FD);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  //supabase 
  final SupabaseClient supabase = Supabase.instance.client;
  List<Device> devices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    setState(() => isLoading = true);
    final response = await supabase.from('listings').select().eq('is_available', true);
    final List<Device> fetchedDevices = [];

    for (final item in response as List<dynamic>) {
      fetchedDevices.add(Device(
        id: item['id'].toString(),
        name: item['name'] ?? '',
        brand: item['brand'] ?? '',
        pricePerDay: (item['price_per_day'] ?? 0).toDouble(),
        imageUrl: item['image_url'] ?? '',
        isAvailable: item['is_available'] ?? true,
        maxRentalDays: item['max_rental_days'] ?? 0,
        condition: item['condition'] ?? '',
        description: item['description'] ?? '',
        category: item['category'] ?? '',
        bookedSlots: (item['booked_slots'] as List<dynamic>? ?? [])
            .map((e) => DateTime.parse(e))
            .toList(),
        deposit: (item['deposit'] as num?)?.toDouble(),
        specifications: item['specifications'] ?? '',
        location: item['location'] ?? '',
      ));
    }


    setState(() {
      devices = fetchedDevices;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pinjam',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: primaryBlue,
                        ),
                      ),
                      Text(
                        'Tech',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildUserInfo(context),
                  const SizedBox(height: 20),
                  _buildSearchBar(context),
                  const SizedBox(height: 20),
                  Text(
                    "Available Devices",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 15),
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
                      final device = devices[index];
                      return _buildDeviceCard(device);
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDeviceCard(Device device) {
return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailPage(
            device: {
            "name": device.name,
            "pricePerDay": device.pricePerDay,
            "description": device.description,
            "image": device.imageUrl,
}

          ),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: blueLight,
        border: Border.all(color: primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.network(
              device.imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.device_unknown, size: 50),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 6),
                Text(
                  "RM ${device.pricePerDay.toStringAsFixed(2)}/day",
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: primaryBlue,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.circle,
                        size: 10,
                        color:
                            device.isAvailable ? Colors.green : Colors.red),
                    const SizedBox(width: 6),
                    Text(device.isAvailable ? "Available" : "Not Available",
                        style: GoogleFonts.poppins(fontSize: 12)),
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
Widget _buildUserInfo(BuildContext context) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Hello!", style: GoogleFonts.poppins(color: textLight)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              "Jaafar",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: blueLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryBlue.withOpacity(0.3)),
              ),
              child: Text(
                'Renter',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
    subtitle: Text(
      "Browse available devices",
      style: GoogleFonts.poppins(color: textLight),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            );
          },
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.grey[300],
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 26, color: primaryBlue),
          ),
        ),

         // PROFILE ICON
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.grey[300],
            ),
            child: Icon(Icons.person, size: 30, color: primaryBlue),
          )
      ],
    ),
  );
}

Widget _buildSearchBar(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
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
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.search, color: primaryBlue),
          ),
        ),
      ),
    ),
  );
}
}