import 'package:flutter/material.dart';
import 'package:pinjamtech_app/models/device_model.dart';
import '../cart/add_cart.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatefulWidget {
  final Device device;

  const ProductDetailPage({super.key, required this.device});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    final device = widget.device;

    return Scaffold(
      appBar: AppBar(title: Text(device.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DEVICE IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                device.imageUrl,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 240,
                    color: Colors.grey[300],
                    child: const Icon(Icons.device_unknown, size: 80),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // NAME & PRICE
            Text(device.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Price: RM ${device.pricePerDay.toStringAsFixed(2)}/day',
                style: const TextStyle(fontSize: 18, color: Colors.blue)),
            const SizedBox(height: 10),

            // DESCRIPTION
            Text(device.description),
            const SizedBox(height: 10),

            // LOCATION
            Text('Location: ${device.location ?? "N/A"}'),
            const SizedBox(height: 20),

            // DATE PICKER
            Text('Select Rental Dates', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDateRange: startDate != null && endDate != null
                      ? DateTimeRange(start: startDate!, end: endDate!)
                      : null,
                );

                if (picked != null) {
                  setState(() {
                    startDate = picked.start;
                    endDate = picked.end;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month),
                    const SizedBox(width: 10),
                    Text(
                      startDate == null || endDate == null
                          ? 'Select rental dates'
                          : '${DateFormat('dd MMM yyyy').format(startDate!)} → ${DateFormat('dd MMM yyyy').format(endDate!)}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // QUANTITY SELECTOR
            Row(
              children: [
                const Text('Quantity:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                ),
                Text(quantity.toString(), style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () => setState(() => quantity++),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ADD TO CART BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (startDate == null || endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select rental dates")),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddToCartScreen(
                        device: device,
                        startDate: startDate!,
                        endDate: endDate!,
                        quantity: quantity,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}