import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/product_list_screen.dart'; // To access Device model

class CompareScreen extends StatefulWidget {
  final Device device1;
  final Device device2;

  const CompareScreen({
    Key? key,
    required this.device1,
    required this.device2,
  }) : super(key: key);

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  // Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  
  // Comparison categories
  final List<ComparisonItem> _comparisonItems = [
    ComparisonItem(title: 'Rental Price', unit: '/day'),
    ComparisonItem(title: 'Availability'),
    ComparisonItem(title: 'Max Rental Days', unit: 'days'),
    ComparisonItem(title: 'Condition'),
    ComparisonItem(title: 'Brand'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Compare Items',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.rotate_right, color: Colors.black),
            onPressed: () {
              // Toggle landscape/portrait
              // We'll implement this later
            },
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.landscape
              ? _buildLandscapeView()
              : _buildPortraitView();
        },
      ),
    );
  }

  Widget _buildPortraitView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Device Cards (stacked vertically)
          _buildDeviceCard(widget.device1),
          const SizedBox(height: 16),
          _buildDeviceCard(widget.device2),
          const SizedBox(height: 24),
          
          // Comparison Table
          _buildComparisonTable(),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildLandscapeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device 1 (left side)
          Expanded(
            child: Column(
              children: [
                _buildDeviceCard(widget.device1),
                const SizedBox(height: 16),
                _buildComparisonColumn(widget.device1),
              ],
            ),
          ),
          
          // VS Separator
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey[300],
          ),
          
          // Device 2 (right side)
          Expanded(
            child: Column(
              children: [
                _buildDeviceCard(widget.device2),
                const SizedBox(height: 16),
                _buildComparisonColumn(widget.device2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Device device) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
              image: device.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(device.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: device.imageUrl.isEmpty
                ? const Icon(Icons.devices, size: 30, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          
          // Device Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'RM ${device.pricePerDay.toStringAsFixed(0)}/day',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: device.isAvailable
                            ? Colors.green[50]
                            : Colors.red[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: device.isAvailable
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      child: Text(
                        device.isAvailable ? 'Available' : 'Not Available',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: device.isAvailable
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparison Details',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),
          
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Feature',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.device1.name.split(' ')[0], // Short name
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: primaryBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.device2.name.split(' ')[0], // Short name
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: primaryBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          // Comparison Rows
          ..._comparisonItems.map((item) {
            return _buildComparisonRow(item);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(ComparisonItem item) {
    String value1 = _getComparisonValue(widget.device1, item.title);
    String value2 = _getComparisonValue(widget.device2, item.title);
    
    bool isBetter = _isValueBetter(value1, value2, item.title);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '${item.title}${item.unit != null ? " (${item.unit})" : ""}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: textDark,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: isBetter ? Colors.green[50] : null,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value1,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isBetter ? Colors.green : textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: !isBetter ? Colors.green[50] : null,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value2,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: !isBetter ? Colors.green : textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonColumn(Device device) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          ..._comparisonItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: textLight,
                    ),
                  ),
                  Text(
                    _getComparisonValue(device, item.title),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: primaryBlue),
            ),
            child: Text(
              'Back to List',
              style: GoogleFonts.poppins(
                color: primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Add to cart or rent functionality
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: primaryBlue,
            ),
            child: Text(
              'Rent Now',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getComparisonValue(Device device, String title) {
    switch (title) {
      case 'Rental Price':
        return 'RM ${device.pricePerDay.toStringAsFixed(0)}';
      case 'Availability':
        return device.isAvailable ? 'Available' : 'Not Available';
      case 'Max Rental Days':
        return '${device.maxRentalDays} days';
      case 'Condition':
        return device.condition;
      case 'Brand':
        return device.brand;
      default:
        return 'N/A';
    }
  }

  bool _isValueBetter(String value1, String value2, String title) {
    if (title == 'Rental Price') {
      // Lower price is better
      double price1 = double.tryParse(value1.replaceAll('RM ', '')) ?? 0;
      double price2 = double.tryParse(value2.replaceAll('RM ', '')) ?? 0;
      return price1 <= price2;
    } else if (title == 'Availability') {
      // Available is better than Not Available
      return value1 == 'Available' && value2 != 'Available';
    } else if (title == 'Max Rental Days') {
      // Higher days is better
      int days1 = int.tryParse(value1.replaceAll(' days', '')) ?? 0;
      int days2 = int.tryParse(value2.replaceAll(' days', '')) ?? 0;
      return days1 >= days2;
    } else if (title == 'Condition') {
      // Condition comparison (simplified)
      List<String> conditionRank = ['New', 'Rarely used', 'Good', 'Fair', 'Poor'];
      int rank1 = conditionRank.indexOf(value1);
      int rank2 = conditionRank.indexOf(value2);
      if (rank1 == -1) rank1 = conditionRank.length;
      if (rank2 == -1) rank2 = conditionRank.length;
      return rank1 <= rank2; // Lower index is better
    }
    return false;
  }
}

class ComparisonItem {
  final String title;
  final String? unit;

  ComparisonItem({required this.title, this.unit});
}