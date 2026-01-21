import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinjamtech_app/services/booking_service.dart';
import 'package:pinjamtech_app/services/notification_service.dart'; // ADD THIS
import 'payment_success.dart';

class MakePaymentScreen extends StatefulWidget {
  final double totalPrice;
  const MakePaymentScreen({super.key, required this.totalPrice});

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  bool isProcessing = true;
  String message = 'Payment is being processed...';

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  Future<void> _processPayment() async {
    try {
      final bookingService = BookingService();
      await bookingService.checkoutCart();

      // Simulate delay for payment processing
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // SHOW ANDROID-STYLE NOTIFICATION
      NotificationService.showAndroidStyleNotification(
        context,
        title: 'Booking Confirmed! ✅',
        message: 'Your booking has been confirmed successfully',
        icon: Icons.check_circle,
        playSound: true,
        vibrate: true,
      );

      // Wait a bit before navigating
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PaymentSuccessScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isProcessing = false;
        message = 'Payment failed: $e';
      });
      
      // SHOW ERROR NOTIFICATION
      NotificationService.showAndroidStyleNotification(
        context,
        title: 'Payment Failed',
        message: 'There was an error processing your payment',
        icon: Icons.error,
        playSound: true,
        vibrate: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Processing Payment')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isProcessing)
              const CircularProgressIndicator()
            else
              const Icon(Icons.error, color: Colors.red, size: 60),
            const SizedBox(height: 20),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}