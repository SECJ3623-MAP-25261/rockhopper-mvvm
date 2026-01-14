import 'package:flutter/material.dart';
import 'package:pinjamtech_app/services/booking_service.dart';
import 'package:intl/intl.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  final BookingService bookingService = BookingService();
  bool isLoading = true;
  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => isLoading = true);

    try {
      // Call BookingService to get user bookings
      final userBookings = await bookingService.getUserBookings();
      setState(() {
        bookings = userBookings;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error loading bookings: $e');
    }
  }

  String formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? const Center(child: Text('No bookings found.'))
              : ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(booking['listing_name'] ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rental Days: ${booking['rental_days']}'),
                            Text('Total Price: RM${booking['total_price'].toStringAsFixed(2)}'),
                            Text(
                              'Status: ${booking['status']}',
                              style: TextStyle(
                                color: booking['status'] == 'pending'
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                            Text(
                                'From ${formatDate(booking['start_date'])} to ${formatDate(booking['end_date'])}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
