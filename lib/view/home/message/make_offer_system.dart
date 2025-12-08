import 'package:flutter/material.dart';

// Reusable Make Offer Button Widget
class MakeOfferButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MakeOfferButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.local_offer_outlined),
        label: const Text(
          "Make Offer",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// Offer Bottom Sheet Widget
class OfferBottomSheet extends StatefulWidget {
  final String itemName;
  final String currentPrice;
  final TextEditingController offerPriceController;
  final TextEditingController offerDaysController;
  final Function(String price, String days) onSendOffer;

  const OfferBottomSheet({
    super.key,
    required this.itemName,
    required this.currentPrice,
    required this.offerPriceController,
    required this.offerDaysController,
    required this.onSendOffer,
  });

  @override
  State<OfferBottomSheet> createState() => _OfferBottomSheetState();
}

class _OfferBottomSheetState extends State<OfferBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  double? calculatedTotal;

  @override
  void initState() {
    super.initState();
    _calculateTotal();
    widget.offerPriceController.addListener(_calculateTotal);
    widget.offerDaysController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    widget.offerPriceController.removeListener(_calculateTotal);
    widget.offerDaysController.removeListener(_calculateTotal);
    super.dispose();
  }

  void _calculateTotal() {
    if (widget.offerPriceController.text.isNotEmpty &&
        widget.offerDaysController.text.isNotEmpty) {
      try {
        double price = double.tryParse(widget.offerPriceController.text) ?? 0;
        int days = int.tryParse(widget.offerDaysController.text) ?? 1;
        setState(() {
          calculatedTotal = price * days;
        });
      } catch (e) {
        setState(() {
          calculatedTotal = null;
        });
      }
    } else {
      setState(() {
        calculatedTotal = null;
      });
    }
  }

  void _submitOffer() {
    if (_formKey.currentState!.validate()) {
      widget.onSendOffer(
        widget.offerPriceController.text,
        widget.offerDaysController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              "Make Offer",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Negotiate the price for ${widget.itemName}",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Offer Price Input
                  TextFormField(
                    controller: widget.offerPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Your Offer Price (per day)",
                      hintText: "Enter amount",
                      prefixText: "RM ",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixText: "/day",
                      prefixStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an offer price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Rental Days Input
                  TextFormField(
                    controller: widget.offerDaysController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Rental Duration",
                      hintText: "Number of days",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixText: "days",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter number of days';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      int days = int.parse(value);
                      if (days < 1) {
                        return 'Minimum 1 day';
                      }
                      if (days > 30) {
                        return 'Maximum 30 days';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Current Price for Reference
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Original Price",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          "RM ${widget.currentPrice}/day",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Total Calculation
                  if (calculatedTotal != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Amount",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "RM ${calculatedTotal!.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submitOffer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Send Offer",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Offer Message Generator Function
String createOfferMessage(String price, String days) {
  String offerMessage = "📋 **Offer Made:**\n";
  offerMessage += "• Price: RM $price/day\n";
  offerMessage += "• Duration: $days day${days == "1" ? "" : "s"}\n";
  double total = double.parse(price) * int.parse(days);
  offerMessage += "• Total: RM ${total.toStringAsFixed(2)}";
  return offerMessage;
}