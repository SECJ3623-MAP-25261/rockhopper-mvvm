import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'attachment_menu.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ImagePicker _picker = ImagePicker();
  
  // Function to pick an image (camera or gallery)
  Future<void> _pickImage(String source) async {
    XFile? pickedFile;

    if (source == 'Camera') {
      pickedFile = await _picker.pickImage(source: ImageSource.camera);
    } else if (source == 'Photo') {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    }

    if (pickedFile != null) {
      // Handle the picked image (e.g., display it or send it)
      print("Picked image: ${pickedFile.path}");
    }
  }

  // Function to get the user's location
  Future<void> _getLocation() async {
    Position position = await _determinePosition();
    print("Location: Latitude ${position.latitude}, Longitude ${position.longitude}");
    // You can send the location to the chat or display it
  }

  // Check for location permission
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, so request permission
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error('Location permissions are denied');
      }
    }

    // Get the current position
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Handle the attachment selected action
  void _onAttachmentSelected(String attachmentType) {
    if (attachmentType == 'Camera' || attachmentType == 'Photo') {
      _pickImage(attachmentType); // Call the pick image function
    } else if (attachmentType == 'Location') {

Future<void> _checkLocationPermission() async {
  // Check for location permission
  LocationPermission permission = await Geolocator.checkPermission();
  
  // If permission is denied, ask for permission
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  // If permanently denied, show an error
  if (permission == LocationPermission.deniedForever) {
    // You can show a dialog here telling the user that location is needed
    print('Location permissions are permanently denied');
    return Future.error('Location permissions are permanently denied');
  }

  // If permission is granted, proceed to fetch the location
  _getLocation();
}
 // Call the location function
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Screen"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              // Chat content can go here
            ),
          ),
          AttachmentMenu(onAttachmentSelected: _onAttachmentSelected),
        ],
      ),
    );
  }
}
