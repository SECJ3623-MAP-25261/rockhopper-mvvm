// edit_listing.dart (updated for Device model)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'edit_listing_windows.dart';
import 'package:pinjamtech_app/models/device_model.dart';

class EditListing extends StatefulWidget {
  final Device device;
  final List<DateTime> bookedSlots;

  const EditListing({
    Key? key,
    required this.device,
    this.bookedSlots = const [],
  }) : super(key: key);

  @override
  State<EditListing> createState() => _EditListingState();
}

class _EditListingState extends State<EditListing> {
  // Colors from your design system
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color background = Color(0xFFF5F5F5);

  DateTime focusedDay = DateTime.now();

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Delete Listing",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this listing?\nThis action cannot be undone.",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  color: textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(
                "Delete",
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // close popup
                _deleteListing();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteListing() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Listing deleted",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: primaryGreen,
      ),
    );

    Navigator.pop(context); // go back after delete
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          widget.device.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit_window') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditListingWindows(
                      device: widget.device,
                    ),
                  ),
                );
              }
              if (value == 'delete') {
                _confirmDelete();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'edit_window',
                  child: Text(
                    'Edit Listing',
                    style: GoogleFonts.poppins(),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text(
                    'Delete Listing',
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE - Fixed to maintain aspect ratio
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.device.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[100],
                      child: Icon(
                        Icons.device_unknown,
                        size: 60,
                        color: textLight,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // PRODUCT INFO CARD
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.device.name,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'RM ${widget.device.pricePerDay.toStringAsFixed(2)}/day',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.device.isAvailable 
                              ? primaryGreen
                              : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 10,
                              color: widget.device.isAvailable 
                                  ? primaryGreen 
                                  : Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.device.isAvailable ? "Available" : "Not Available",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: widget.device.isAvailable 
                                    ? primaryGreen 
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildInfoRow("Brand", widget.device.brand),
                  _buildInfoRow("Condition", widget.device.condition),
                  _buildInfoRow("Category", widget.device.category),
                  _buildInfoRow("Max Rental Days", "${widget.device.maxRentalDays} days"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // DESCRIPTION CARD
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Description",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.device.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: textLight,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CALENDAR (READ-ONLY) CARD
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20, color: primaryBlue),
                      const SizedBox(width: 8),
                      Text(
                        "Booked Slots",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  TableCalendar(
                    locale: "en_US",
                    rowHeight: 40,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                      leftChevronIcon: Icon(Icons.chevron_left, color: primaryBlue),
                      rightChevronIcon: Icon(Icons.chevron_right, color: primaryBlue),
                      headerPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        color: textLight,
                      ),
                      weekendStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        color: textLight,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: textDark,
                      ),
                      weekendTextStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: textDark,
                      ),
                      todayDecoration: BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryBlue, width: 1),
                      ),
                      todayTextStyle: GoogleFonts.poppins(
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: GoogleFonts.poppins(
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    firstDay: DateTime.now().subtract(const Duration(days: 30)),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: focusedDay,
                    availableGestures: AvailableGestures.none, // read-only

                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        if (widget.bookedSlots.any((d) => isSameDay(d, day))) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}