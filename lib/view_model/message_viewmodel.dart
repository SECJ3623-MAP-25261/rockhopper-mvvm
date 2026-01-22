import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:geolocator/geolocator.dart'; 
import 'package:pinjamtech_app/view/profile/view_renter_profile.dart';

class MessageViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> messages = [];
  final ImagePicker _picker = ImagePicker();

  // Initialize messages with initial inquiry
  void initializeMessages(String initialInquiry, String chatName) {
    messages.add({
      "fromMe": false,
      "text": initialInquiry,
      "time": "10:30 AM",
      "senderName": chatName,
    });
    notifyListeners();
  }

  // Add a new message
  void sendMessage(String text, String senderName) {
    if (text.isEmpty) return;

    messages.add({
      "fromMe": true,
      "text": text,
      "time": _formatTime(DateTime.now()),
      "senderName": senderName,
    });

    notifyListeners();
  }

  // Handle picking image from gallery or camera
  Future<void> _pickImage(String source) async {
    XFile? pickedFile;

    if (source == 'Camera') {
      pickedFile = await _picker.pickImage(source: ImageSource.camera);
    } else if (source == 'Gallery') {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    }

    if (pickedFile?.path != null) {
      messages.add({
        "fromMe": true,
        "text": "📸 Image attached",
        "time": _formatTime(DateTime.now()),
        "senderName": "You",
        "image": pickedFile?.path,
      });
      notifyListeners();
    }
  }

  // Get the user's current location
  Future<void> getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    messages.add({
      "fromMe": true,
      "text": "📍 Location attached",
      "time": _formatTime(DateTime.now()),
      "senderName": "You",
    });
    notifyListeners();
  }

  // Format the time to show in messages
  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    return "$hour:${time.minute.toString().padLeft(2, '0')} $period";
  }

  // Handle quick replies and attachment
  void sendQuickReply(String text, int index) {
  // Send message with text and sender's name
  sendMessage(text, "You");
}


  // Handle attachment type (Camera, Gallery, Location)
  void onAttachmentSelected(String attachmentType) {
    if (attachmentType == 'Camera' || attachmentType == 'Gallery') {
      _pickImage(attachmentType);
    } else if (attachmentType == 'Location') {
      getLocation();
    }
  }
}