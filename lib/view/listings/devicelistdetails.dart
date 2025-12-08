import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../cart/renting_cart.dart';
import 'package:pinjamtech_app/models/device_model.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> device;

  const ProductDetailPage({super.key, required this.device});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  DateTime? startDate;
  DateTime? endDate;

  final Color primaryBlue = const Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    final device = widget.device;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(device["name"], style: GoogleFonts.poppins()),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // DEVICE IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                device["image"],
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // NAME + PRICE 
            Text(
              device["name"],
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "RM ${device["pricePerDay"]}/day",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),

            const SizedBox(height: 20),

            // DESCRIPTION
            Text(
              device["description"],
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 25),

            // QUANTITY SELECTOR
            Text("Quantity", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (quantity > 1) setState(() => quantity--);
                  },
                  icon: const Icon(Icons.remove_circle),
                ),
                Text(
                  quantity.toString(),
                  style: GoogleFonts.poppins(fontSize: 18),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => quantity++);
                  },
                  icon: const Icon(Icons.add_circle),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // DATE PICKER
            Text("Rental Duration", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: pickDates,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.black54),
                    const SizedBox(width: 10),
                    Text(
                      startDate == null
                          ? "Select rental dates"
                          : "${DateFormat('dd MMM yyyy').format(startDate!)} → ${DateFormat('dd MMM yyyy').format(endDate!)}",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ADD TO CART BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _addToCart,
                child: Text(
                  "Add to Cart",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // PICK RENTAL DATES
  Future<void> pickDates() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  // ADD ITEM TO CART
  Future<void> _addToCart() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select rental dates")),
      );
      return;
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You must be logged in")),
        );
        return;
      }

      //  Get or create cart
      final cartResponse = await Supabase.instance.client
          .from('carts')
          .select('id')
          .eq('renter_id', user.id)
          .single()
          .maybeSingle();

      String cartId;
      if (cartResponse != null && cartResponse['id'] != null) {
        cartId = cartResponse['id'];
      } else {
        final newCart = await Supabase.instance.client
            .from('carts')
            .insert({'renter_id': user.id})
            .select('id')
            .single();
        cartId = newCart['id'];
      }

      //  Insert into cart_items
      await Supabase.instance.client.from('cart_items').insert({
        'cart_id': cartId,
        'listing_id': widget.device['id'],
        'start_date': startDate!.toIso8601String(),
        'end_date': endDate!.toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to Cart")),
      );

      //  Navigate to RentingCartScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RentingCartScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add to cart: $e")),
      );
    }
  }
}
