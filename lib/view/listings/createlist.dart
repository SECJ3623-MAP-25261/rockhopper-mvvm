import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this
import 'package:geolocator/geolocator.dart';
import 'package:pinjamtech_app/models/device_model.dart';
import 'package:pinjamtech_app/view/home/home_roles/rentee_home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../home/rentee.dart';
import 'package:path/path.dart' as p;

class CreateList extends StatefulWidget {
  const CreateList({Key? key}) : super(key: key);
  
  @override
  State<CreateList> createState() => _CreateListState();
}

class _CreateListState extends State<CreateList> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _specificationController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _rentDurationController = TextEditingController();
  
  String? selectedCategory;
  String? selectedCondition;
  String? selectedMaxDays = '30';
  bool isAvailable = true;
  
  Position? _currentPosition;
  String _locationMessage = 'Location not set';
  bool _isLoadingLocation = false;
  bool _isPublishing = false; // Add loading state for publishing

  @override
  void initState() {
    super.initState();
    selectedCondition = 'Good';
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _descriptionController.dispose();
    _specificationController.dispose();
    _locationController.dispose();
    _brandController.dispose();
    _rentDurationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _locationMessage = 'Location services are disabled';
          _isLoadingLocation = false;
        });
        _showLocationServiceDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() {
            _locationMessage = 'Location permission denied';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationMessage = 'Location permission permanently denied';
          _isLoadingLocation = false;
        });
        _showPermissionDialog();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _locationMessage = 'Lat: ${position.latitude.toStringAsFixed(6)}, Long: ${position.longitude.toStringAsFixed(6)}';
        _locationController.text = _locationMessage;
        _isLoadingLocation = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location captured successfully!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationMessage = 'Error getting location: $e';
        _isLoadingLocation = false;
      });
    }
  }
//supabase
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      if (!mounted) return;
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToSupabase(File image) async {
    final supabase = Supabase.instance.client;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';

    try {
      await supabase.storage.from('listing-images').upload(
        fileName,
        image,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final publicUrl = supabase.storage.from('listing-images').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      if (!mounted) return null;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Image upload failed: $e',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
      return null;
    }
  }
//supabase
  Future<void> _saveToSupabase(Device newDevice) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
  print("ERROR: User not logged in");
  return;
}


    try {
      await supabase.from('listings').insert({
        'id': newDevice.id,
        'name': newDevice.name,
        'brand': newDevice.brand,
        'price_per_day': newDevice.pricePerDay,
        'deposit': newDevice.deposit,
        'category': newDevice.category,
        'condition': newDevice.condition,
        'is_available': newDevice.isAvailable,
        'max_rental_days': newDevice.maxRentalDays,
        'description': newDevice.description,
        'specifications': newDevice.specifications,
        'location': newDevice.location,
        'image_url': newDevice.imageUrl,
        'booked_slots': newDevice.bookedSlots,
        'user_id': userId,
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Listing saved to Supabase!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving listing: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      rethrow; // Re-throw to handle in calling function
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Location Services Disabled',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Please enable location services to continue.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: Text(
              'Open Settings',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Location Permission Required',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Location permission is permanently denied. Please enable it in app settings.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: Text(
              'Open Settings',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _publishListing() async {
    // Prevent multiple submissions
    if (_isPublishing || !mounted) return;
    
    setState(() {
      _isPublishing = true;
    });

    try {
      // Upload image before saving listing
      String imageUrl = 'https://via.placeholder.com/400x300?text=${Uri.encodeComponent(_itemNameController.text)}';

      if (_selectedImage != null) {
        final uploadedUrl = await _uploadImageToSupabase(_selectedImage!);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      // Validate required fields
      if (_itemNameController.text.isEmpty || 
          _priceController.text.isEmpty || 
          selectedCategory == null) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please fill in all required fields',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate price
      final price = double.tryParse(_priceController.text);
      if (price == null || price <= 0) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter a valid price',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create Device object with ALL fields
      final newDevice = Device(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _itemNameController.text.trim(),
        brand: _brandController.text.trim().isNotEmpty ? _brandController.text.trim() : 'Generic',
        pricePerDay: price,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
        maxRentalDays: int.tryParse(selectedMaxDays ?? '30') ?? 30,
        condition: selectedCondition ?? 'Good',
        description: _descriptionController.text.trim(),
        category: selectedCategory ?? 'General',
        bookedSlots: [],
        deposit: double.tryParse(_depositController.text),
        specifications: _specificationController.text.trim(),
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : _locationMessage,
      );

      // Save to Supabase
      await _saveToSupabase(newDevice);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Listing published successfully!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
      
      // Delay navigation slightly to show success message
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to publish listing: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Listing',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isPublishing ? null : () {
            Navigator.pushReplacement(context, 
             MaterialPageRoute(builder: (_) => const RenteeMain()),);
          },
        ),
        actions: [
          _isPublishing
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _publishListing,
                  child: Text(
                    'Publish',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo Section
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[400],
                        ),
                        child: _selectedImage == null
                            ? const Icon(Icons.camera, size: 50, color: Colors.white)
                            : ClipOval(
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                  child:InkWell(
                   onTap: _isPublishing ? null : () => _showImagePickerOptions(),
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Item Name
            TextField(
              controller: _itemNameController,
              enabled: !_isPublishing,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                labelText: 'Item Name *',
                labelStyle: GoogleFonts.poppins(),
                border: const OutlineInputBorder(),
                hintText: 'e.g., MacBook Pro M2',
                hintStyle: GoogleFonts.poppins(),
              ),
            ),
            const SizedBox(height: 20),
            
            // Brand
            TextField(
              controller: _brandController,
              enabled: !_isPublishing,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                labelText: 'Brand (Optional)',
                labelStyle: GoogleFonts.poppins(),
                border: const OutlineInputBorder(),
                hintText: 'e.g., Apple, Samsung, Dell',
                hintStyle: GoogleFonts.poppins(),
              ),
            ),
            const SizedBox(height: 20),
            
            // Rental Price
            TextField(
              controller: _priceController,
              enabled: !_isPublishing,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                labelText: 'Rental Price per Day *',
                labelStyle: GoogleFonts.poppins(),
                border: const OutlineInputBorder(),
                prefixText: 'RM ',
                hintText: 'Enter daily rental price',
                hintStyle: GoogleFonts.poppins(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),

            // Deposit
            TextField(
              controller: _depositController,
              enabled: !_isPublishing,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                labelText: 'Deposit (Optional)',
                labelStyle: GoogleFonts.poppins(),
                border: const OutlineInputBorder(),
                prefixText: 'RM ',
                hintText: 'Enter security deposit amount',
                hintStyle: GoogleFonts.poppins(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            
            // Category Section
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Category *',
                labelStyle: GoogleFonts.poppins(),
                border: const OutlineInputBorder(),
              ),
              value: selectedCategory,
              items: <String>['Laptops', 'Tablets', 'Phones', 'XR/VR Box', 'Other']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(),
                  ),
                );
              }).toList(),
              onChanged: _isPublishing ? null : (String? newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
            ),
            
            // Condition Section
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Condition',
                labelStyle: GoogleFonts.poppins(),
                border: const OutlineInputBorder(),
              ),
              value: selectedCondition,
              items: <String>['Like New', 'Excellent', 'Good', 'Fair', 'Poor']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(),
                  ),
                );
              }).toList(),
              onChanged: _isPublishing ? null : (String? newValue) {
                setState(() {
                  selectedCondition = newValue;
                });
              },
            ),
            
            // Max Rental Days
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Maximum Rental Period',
                labelStyle: GoogleFonts.poppins(),
                border: const OutlineInputBorder(),
                hintText: 'Select maximum rental days',
                hintStyle: GoogleFonts.poppins(),
              ),
              value: selectedMaxDays,
              items: <String>['7', '15', '30', '60', '90']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    '$value days',
                    style: GoogleFonts.poppins(),
                  ),
                );
              }).toList(),
              onChanged: _isPublishing ? null : (String? newValue) {
                setState(() {
                  selectedMaxDays = newValue;
                });
              },
            ),
            
            // Availability Toggle
            const SizedBox(height: 10),
            SwitchListTile(
              title: Text(
                'Make item available for rent',
                style: GoogleFonts.poppins(),
              ),
              subtitle: Text(
                'Turn off if item is being repaired',
                style: GoogleFonts.poppins(),
              ),
              value: isAvailable,
              onChanged: _isPublishing ? null : (value) {
                setState(() {
                  isAvailable = value;
                });
              },
              activeColor: Colors.green,
            ),

            // Description
            TextField(
              controller: _descriptionController,
              enabled: !_isPublishing,
              style: GoogleFonts.poppins(),
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: GoogleFonts.poppins(),
                border: const OutlineInputBorder(),
                hintText: 'Describe your item in detail',
                hintStyle: GoogleFonts.poppins(),
              ),
            ),
            
            const SizedBox(height: 20),
            // Specification
            TextField(
              controller: _specificationController,
              enabled: !_isPublishing,
              style: GoogleFonts.poppins(),
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Specification',
                labelStyle: GoogleFonts.poppins(),
                border: const OutlineInputBorder(),
                hintText: 'Enter device specifications (RAM, Storage, etc.)',
                hintStyle: GoogleFonts.poppins(),
              ),
            ),
            
            const SizedBox(height: 20),
            // Location Section
            Text(
              'Location',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: _currentPosition != null
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _locationMessage,
                          style: GoogleFonts.poppins(
                            color: _currentPosition != null
                                ? Colors.black87
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_isLoadingLocation || _isPublishing) ? null : _getCurrentLocation,
                      icon: _isLoadingLocation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(
                        _isLoadingLocation
                            ? 'Getting Location...'
                            : 'Get Current Location',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _locationController,
                    enabled: !_isPublishing,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      labelText: 'Or enter manually',
                      labelStyle: GoogleFonts.poppins(),
                      border: const OutlineInputBorder(),
                      hintText: 'Where is the item located?',
                      hintStyle: GoogleFonts.poppins(),
                      prefixIcon: const Icon(Icons.edit_location),
                    ),
                  ),
                ],
              ),
            ),
            
            // Submit Button at the bottom
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isPublishing ? null : _publishListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isPublishing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Submit Listing',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Text(
                'or use the "Publish" button in the top bar',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
            
            // Required fields note
            const SizedBox(height: 20),
            Text(
              '* Required fields: Item Name, Price, Category',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
     context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Profile Photo',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, size: 35, color: Colors.blue[700]),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}