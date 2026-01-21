import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinjamtech_app/models/device_model.dart';
import 'package:pinjamtech_app/services/rentingcart_service.dart';
import 'package:pinjamtech_app/services/booking_service.dart';
import '../cart/renting_cart.dart';

class AddToCartScreen extends StatelessWidget {
  final Device device;
  final DateTime startDate;
  final DateTime endDate;
  final int quantity;

  const AddToCartScreen({
    super.key,
    required this.device,
    required this.startDate,
    required this.endDate,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final RentingCartService cartService = RentingCartService();

    return Scaffold(
      appBar: AppBar(title: Text("Add to Cart")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device: ${device.name}'),
            Text('Quantity: $quantity'),
            Text('From: ${startDate.toIso8601String()}'),
            Text('To: ${endDate.toIso8601String()}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 1️⃣ Add item to cart
                await cartService.addToCart(
                  device: device,
                  startDate: startDate,
                  endDate: endDate,
                  quantity: quantity,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to Cart')),
                );

                // 2️⃣ Navigate to CartScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              child: const Text("Confirm Add to Cart"),
            ),
          ],
        ),
      ),
    );
  }
}
