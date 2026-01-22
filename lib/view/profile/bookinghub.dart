import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingHub extends StatefulWidget {
  const BookingHub({super.key});

  @override
  State<BookingHub> createState() => _BookingHubState();
}

class _BookingHubState extends State<BookingHub> {
  final supabase = Supabase.instance.client;
  late Future<List<dynamic>> bookingsFuture;

  @override
  void initState() {
    super.initState();
    bookingsFuture = fetchBookings();
  }

  Future<List<dynamic>> fetchBookings() async {
    final userId = supabase.auth.currentUser!.id;

    return await supabase
        .from('bookings')
        .select()
        .eq('rentee_id', userId)
        .eq('status', 'paid')
        .order('created_at', ascending: false);
  }

  Future<void> confirmBooking(String bookingId, String listingId) async {
    // 1. Update booking status
    await supabase
        .from('bookings')
        .update({'status': 'confirmed'})
        .eq('id', bookingId);

    // 2. Keep listing unavailable
    await supabase
        .from('listings')
        .update({'is_available': false})
        .eq('id', listingId);

    setState(() {
      bookingsFuture = fetchBookings();
    });
  }

  Future<void> rejectBooking(String bookingId, String listingId) async {
    // 1. Update booking status
    await supabase
        .from('bookings')
        .update({'status': 'rejected'})
        .eq('id', bookingId);

    // 2. Make listing available again
    await supabase
        .from('listings')
        .update({'is_available': true})
        .eq('id', listingId);

    setState(() {
      bookingsFuture = fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Hub')),
      body: FutureBuilder<List<dynamic>>(
        future: bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bookings to confirm'));
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['listing_name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'RM ${booking['price_per_day']} x ${booking['rental_days']} days',
                      ),
                      Text(
                        'Total: RM ${booking['total_price']}',
                      ),
                      Text(
                        'From ${booking['start_date']} to ${booking['end_date']}',
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () => confirmBooking(
                              booking['id'],
                              booking['listing_id'],
                            ),
                            child: const Text('Confirm'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => rejectBooking(
                              booking['id'],
                              booking['listing_id'],
                            ),
                            child: const Text('Reject'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
