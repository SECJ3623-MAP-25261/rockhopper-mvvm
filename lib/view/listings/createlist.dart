import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:pinjamtech_app/view_model/createlist_viewmodel.dart';

class CreateList extends StatelessWidget {
  const CreateList({Key? key}) : super(key: key);

  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color backgroundGrey = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateListingViewModel(),
      child: const _CreateListingBody(),
    );
  }
}

class _CreateListingBody extends StatelessWidget {
  const _CreateListingBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateListingViewModel>();

    return Scaffold(
      backgroundColor: CreateList.backgroundGrey,
      appBar: _buildAppBar(context, vm),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageSection(context, vm),
            _buildFormSection(context, vm),
          ],
        ),
      ),
    );
  }

  // ============ APP BAR ============
  PreferredSizeWidget _buildAppBar(BuildContext context, CreateListingViewModel vm) {
    return AppBar(
      elevation: 0,
      backgroundColor: CreateList.primaryGreen,
      title: Text(
        'Create New Listing',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: vm.isPublishing ? null : () => Navigator.pop(context),
      ),
      actions: [
        vm.isPublishing
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : TextButton.icon(
                onPressed: () => _handlePublish(context, vm),
                icon: const Icon(Icons.check, color: Colors.white, size: 20),
                label: Text(
                  'Publish',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ],
    );
  }

  // ============ IMAGE SECTION ============
  Widget _buildImageSection(BuildContext context, CreateListingViewModel vm) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Text(
            'Upload Item Photo',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildImagePicker(context, vm),
          const SizedBox(height: 12),
          Text(
            'Tap the camera icon to add a photo',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context, CreateListingViewModel vm) {
    return Stack(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            border: Border.all(
              color: CreateList.primaryGreen.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: vm.selectedImage == null
              ? Icon(Icons.add_photo_alternate, size: 60, color: Colors.grey[400])
              : ClipOval(
                  child: Image.file(
                    vm.selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: GestureDetector(
            onTap: vm.isPublishing ? null : () => _showImagePickerOptions(context, vm),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: CreateList.primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============ FORM SECTION ============
  Widget _buildFormSection(BuildContext context, CreateListingViewModel vm) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: vm.itemNameController,
              label: 'Item Name',
              hint: 'e.g., MacBook Pro M2',
              required: true,
              icon: Icons.devices,
              enabled: !vm.isPublishing,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: vm.brandController,
              label: 'Brand',
              hint: 'e.g., Apple, Samsung, Dell',
              icon: Icons.branding_watermark,
              enabled: !vm.isPublishing,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Category',
              value: vm.selectedCategory,
              items: const ['Laptops', 'Tablets', 'Phones', 'XR/VR Box', 'Other'],
              required: true,
              icon: Icons.category,
              enabled: !vm.isPublishing,
              onChanged: vm.setCategory,
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Pricing & Rental Terms'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: vm.priceController,
              label: 'Daily Rental Price',
              hint: 'Enter price per day',
              required: true,
              icon: Icons.attach_money,
              prefix: 'RM ',
              enabled: !vm.isPublishing,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: vm.depositController,
              label: 'Security Deposit',
              hint: 'Optional deposit amount',
              icon: Icons.lock_outline,
              prefix: 'RM ',
              enabled: !vm.isPublishing,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Maximum Rental Period',
              value: vm.selectedMaxDays,
              items: const ['7', '15', '30', '60', '90'],
              icon: Icons.calendar_today,
              enabled: !vm.isPublishing,
              onChanged: vm.setMaxDays,
              suffix: ' days',
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Item Details'),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Condition',
              value: vm.selectedCondition,
              items: const ['Like New', 'Excellent', 'Good', 'Fair', 'Poor'],
              icon: Icons.stars,
              enabled: !vm.isPublishing,
              onChanged: vm.setCondition,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: vm.descriptionController,
              label: 'Description',
              hint: 'Describe your item in detail...',
              icon: Icons.description,
              enabled: !vm.isPublishing,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: vm.specificationController,
              label: 'Specifications',
              hint: 'Enter device specs (RAM, Storage, etc.)',
              icon: Icons.settings,
              enabled: !vm.isPublishing,
              maxLines: 4,
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Location'),
            const SizedBox(height: 16),
            _buildLocationSection(context, vm),
            
            const SizedBox(height: 32),
            _buildAvailabilityToggle(vm),
            
            const SizedBox(height: 32),
            _buildPublishButton(context, vm),
            
            const SizedBox(height: 16),
            _buildRequiredFieldsNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: CreateList.primaryGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    bool enabled = true,
    String? prefix,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: CreateList.primaryGreen),
        prefixText: prefix,
        prefixStyle: GoogleFonts.poppins(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CreateList.primaryGreen, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
    bool required = false,
    bool enabled = true,
    String suffix = '',
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: CreateList.primaryGreen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CreateList.primaryGreen, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            '$item$suffix',
            style: GoogleFonts.poppins(),
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
    );
  }

  Widget _buildLocationSection(BuildContext context, CreateListingViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: vm.currentPosition != null 
                    ? CreateList.primaryGreen 
                    : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vm.locationMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: vm.currentPosition != null 
                        ? Colors.black87 
                        : Colors.grey[600],
                    fontWeight: vm.currentPosition != null 
                        ? FontWeight.w500 
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (vm.isLoadingLocation || vm.isPublishing) 
                  ? null 
                  : () => _handleGetLocation(context, vm),
              style: ElevatedButton.styleFrom(
                backgroundColor: CreateList.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              icon: vm.isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.my_location, size: 20),
              label: Text(
                vm.isLoadingLocation ? 'Getting Location...' : 'Get Current Location',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: vm.locationController,
            enabled: !vm.isPublishing,
            style: GoogleFonts.poppins(),
            decoration: InputDecoration(
              labelText: 'Or enter location manually',
              labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
              hintText: 'e.g., Johor Bahru, Malaysia',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.edit_location, color: CreateList.primaryGreen),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CreateList.primaryGreen, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityToggle(CreateListingViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: vm.isAvailable 
            ? CreateList.primaryGreen.withOpacity(0.1) 
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: vm.isAvailable 
              ? CreateList.primaryGreen 
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          'Item Available for Rent',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          vm.isAvailable 
              ? 'Item is ready to be rented'
              : 'Item is currently unavailable',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
        value: vm.isAvailable,
        onChanged: vm.isPublishing ? null : vm.setAvailability,
        activeColor: CreateList.primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPublishButton(BuildContext context, CreateListingViewModel vm) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: vm.isPublishing ? null : () => _handlePublish(context, vm),
        style: ElevatedButton.styleFrom(
          backgroundColor: CreateList.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          disabledBackgroundColor: Colors.grey[300],
        ),
        icon: vm.isPublishing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.publish, size: 24),
        label: Text(
          vm.isPublishing ? 'Publishing...' : 'Publish Listing',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildRequiredFieldsNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Fields marked with * are required',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.blue[900],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ EVENT HANDLERS ============
  void _showImagePickerOptions(BuildContext context, CreateListingViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Choose Image Source',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      _pickImage(context, vm, ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    color: CreateList.primaryGreen,
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      _pickImage(context, vm, ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, CreateListingViewModel vm, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      vm.setImage(File(pickedFile.path));
    }
  }

  Future<void> _handleGetLocation(BuildContext context, CreateListingViewModel vm) async {
    final result = await vm.getCurrentLocation();

    if (!context.mounted) return;

    switch (result) {
      case LocationResult.success:
        _showSnackBar(
          context,
          'Location captured successfully!',
          CreateList.primaryGreen,
          Icons.check_circle,
        );
        break;
      case LocationResult.serviceDisabled:
        _showLocationServiceDialog(context);
        break;
      case LocationResult.permissionDeniedForever:
        _showPermissionDialog(context);
        break;
      case LocationResult.permissionDenied:
      case LocationResult.error:
        _showSnackBar(
          context,
          'Could not get location',
          Colors.red,
          Icons.error_outline,
        );
        break;
    }
  }

  void _showLocationServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Location Services Disabled',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Please enable location services to continue.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CreateList.primaryGreen,
            ),
            child: Text('Open Settings', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Location Permission Required',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Location permission is permanently denied. Please enable it in app settings.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Geolocator.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CreateList.primaryGreen,
            ),
            child: Text('Open Settings', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePublish(BuildContext context, CreateListingViewModel vm) async {
    final result = await vm.publishListing();

    if (!context.mounted) return;

    if (result.success) {
      _showSnackBar(
        context,
        result.message,
        CreateList.primaryGreen,
        Icons.check_circle,
      );
      
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        Navigator.pop(context, result.device);
      }
    } else {
      _showSnackBar(
        context,
        result.message,
        Colors.red,
        Icons.error_outline,
      );
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}