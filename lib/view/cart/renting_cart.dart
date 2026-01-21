import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinjamtech_app/view_model/cart_viewmodel.dart';
import '../payment/make_payment.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RentingCartViewModel()..loadCart(),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Cart')),
        body: Consumer<RentingCartViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) return const Center(child: CircularProgressIndicator());

            if (vm.cartItems.isEmpty) {
              return const Center(child: Text('Your cart is empty.'));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: vm.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = vm.cartItems[index];
                      final listing = item['listings'];
                      return ListTile(
                        title: Text(listing?['name'] ?? 'Unknown'),
                        subtitle: Text(
                          'Price: RM${listing?['price_per_day'] ?? 0} x ${item['rental_days']} days = RM${(listing?['price_per_day'] ?? 0) * (item['rental_days'] ?? 1)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await vm.removeItem(item['id']);
                          },
                        ),
                        leading: Checkbox(
                          value: item['selected'] ?? false,
                          onChanged: (val) {
                            vm.toggleSelection(index, val ?? false);
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Total: RM${vm.totalPrice.toStringAsFixed(2)}'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          final selectedItems = vm.cartItems
                              .where((e) => e['selected'] == true)
                              .toList();
                          if (selectedItems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Select at least one item')),
                            );
                            return;
                          }

                          // Navigate to MakePaymentScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MakePaymentScreen(
                                totalPrice: vm.totalPrice,
                              ),
                            ),
                          );
                        },
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}