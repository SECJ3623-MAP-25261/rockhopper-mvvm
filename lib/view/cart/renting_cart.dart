import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../payment/make_payment.dart';
import 'package:pinjamtech_app/view_model/cart_viewmodel.dart';

class RentingCartScreen extends StatelessWidget {
  const RentingCartScreen({super.key});

  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color background = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RentingCartViewModel(),
      child: const _RentingCartBody(),
    );
  }
}

class _RentingCartBody extends StatelessWidget {
  const _RentingCartBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RentingCartViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Renting Cart',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: RentingCartScreen.primaryBlue,
      ),
      backgroundColor: RentingCartScreen.background,
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.cartItems.isEmpty
              ? Center(
                  child: Text(
                    'Your cart is empty',
                    style: GoogleFonts.poppins(
                        color: RentingCartScreen.textLight),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: vm.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = vm.cartItems[index];
                          final listing = item['listings'];

                          return Card(
                            child: ListTile(
                              leading: Checkbox(
                                value: item['selected'],
                                onChanged: (v) =>
                                    vm.toggleSelection(index, v ?? false),
                              ),
                              title: Text(listing['name']),
                              subtitle:
                                  Text(listing['description'] ?? ''),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () =>
                                    vm.removeItem(item['id']),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Total
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total'),
                              Text(
                                'RM ${vm.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: RentingCartScreen.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: vm.totalPrice == 0
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            MakePaymentScreen(
                                          totalPrice: vm.totalPrice,
                                        ),
                                      ),
                                    );
                                  },
                            child: const Text('Proceed to Booking'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
