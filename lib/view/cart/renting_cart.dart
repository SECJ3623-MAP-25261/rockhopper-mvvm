import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../payment/make_payment.dart';

class RentingCartScreen extends StatefulWidget {
  const RentingCartScreen({super.key});

  @override
  State<RentingCartScreen> createState() => _RentingCartScreenState();
}

class _RentingCartScreenState extends State<RentingCartScreen> {
  // Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color background = Color(0xFFF5F5F5);

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  /// Load cart from supabase
  Future<void> _loadCartItems() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() {
          cartItems = [];
          isLoading = false;
        });
        return;
      }

      // Get renter's cart
      final cart = await supabase
          .from('carts')
          .select('id')
          .eq('renter_id', user.id)
          .maybeSingle();

      if (cart == null) {
        setState(() {
          cartItems = [];
          isLoading = false;
        });
        return;
      }

      // Get cart items with listing details
      final items = await supabase
          .from('cart_items')
          .select('''
            id,
            listing_id,
            start_date,
            end_date,
            listings (
              id,
              name,
              price_per_day,
              description,
              image_url
            )
          ''')
          .eq('cart_id', cart['id']);

      setState(() {
        cartItems = List<Map<String, dynamic>>.from(items).map((item) {
          return {
            ...item,
            'selected': false, // UI only
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Cart load error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  double get totalPrice {
    double total = 0;
    for (final item in cartItems) {
      if (item['selected'] == true) {
        final listing = item['listings'];
        final price = (listing?['price_per_day'] ?? 0).toDouble();
        total += price;
      }
    }
    return total;
  }

  ///Remov e item from cart 
  Future<void> _removeItem(String cartItemId) async {
    await supabase.from('cart_items').delete().eq('id', cartItemId);
    await _loadCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Renting Cart',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? Center(
                  child: Text(
                    'Your cart is empty',
                    style: GoogleFonts.poppins(color: textLight),
                  ),
                )
              : Column(
                  children: [
                    // Cart header
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Icon(Icons.shopping_cart, color: primaryBlue),
                          const SizedBox(width: 8),
                          Text(
                            '${cartItems.length} items in cart',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: textDark,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Select items to checkout',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: textLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Cart items list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          final listing = item['listings'];

                          if (listing == null) return const SizedBox();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Checkbox
                                Checkbox(
                                  value: item['selected'],
                                  activeColor: primaryBlue,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      item['selected'] = value ?? false;
                                    });
                                  },
                                ),

                                // Image
                                Container(
                                  width: 80,
                                  height: 80,
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        listing['image_url'] ?? '',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                // Details
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          listing['name'] ?? '',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: textDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          listing['description'] ?? '',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: textLight,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: primaryBlue,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${item['start_date']} → ${item['end_date']}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: primaryBlue,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              'RM ${listing['price_per_day']}/day',
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                color: primaryGreen,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 6),

                                        /// Delete button
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () => _removeItem(
                                              item['id'],
                                            ),
                                            child: const Text(
                                              'Remove',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    /// Total section
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: textDark,
                                ),
                              ),
                              Text(
                                'RM ${totalPrice.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: totalPrice == 0
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MakePaymentScreen(
                                            totalPrice: totalPrice,
                                          ),
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Proceed to Booking'),
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
