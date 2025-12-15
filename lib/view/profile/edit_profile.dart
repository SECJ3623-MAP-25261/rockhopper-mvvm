import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pinjamtech_app/view_model/editprofile_viewmodel.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  // Theme colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color backgroundGrey = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditProfileViewModel(),
      child: const _EditProfileUI(),
    );
  }
}

class _EditProfileUI extends StatelessWidget {
  const _EditProfileUI();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditProfileViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Update Profile", style: GoogleFonts.poppins(color: EditProfile.textDark, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: EditProfile.backgroundGrey,
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                 _buildImageSection(context, vm),
                  const SizedBox(height: 20),
                  _buildFormSection(context, vm),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await vm.updateProfile();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Profile updated successfully")),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: EditProfile.primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text("Save Changes", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
Widget _buildImageSection(BuildContext context, EditProfileViewModel vm) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Text('Profile Photo', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                child: vm.selectedImage == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : ClipOval(child: Image.file(vm.selectedImage!, fit: BoxFit.cover, width: 100, height: 100)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showImagePickerOptions(context, vm),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: EditProfile.primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Tap to change photo', style: GoogleFonts.poppins(fontSize: 12, color: EditProfile.textLight)),
        ],
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context, EditProfileViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildImageOption(context, Icons.camera_alt, 'Camera', ImageSource.camera, vm),
            _buildImageOption(context, Icons.photo_library, 'Gallery', ImageSource.gallery, vm),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption(BuildContext context, IconData icon, String label, ImageSource source, EditProfileViewModel vm) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        vm.selectImage(source);
      },
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, size: 35, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 14)),
        ],
      ),
    );
  }
  Widget _buildFormSection(BuildContext context, EditProfileViewModel vm) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          _buildProfileField("Full Name", vm.fullNameController.text, () => _showEditDialog(context, "Full Name", vm.fullNameController)),
          const Divider(height: 1, indent: 20),
          _buildProfileField("Phone", vm.phoneController.text, () => _showEditDialog(context, "Phone", vm.phoneController)),
          const Divider(height: 1, indent: 20),
          _buildProfileField("Bio", vm.bioController.text, () => _showEditDialog(context, "Bio", vm.bioController)),
          const Divider(height: 1, indent: 20),
          _buildGenderField(context, vm),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 16, color: EditProfile.textDark)),
            Row(
              children: [
                Text(value.isEmpty ? "Not set" : value, style: GoogleFonts.poppins(color: value.isEmpty ? EditProfile.textLight : EditProfile.textDark)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderField(BuildContext context, EditProfileViewModel vm) {
    return InkWell(
      onTap: () => _showGenderDialog(context, vm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Gender", style: GoogleFonts.poppins(fontSize: 16, color: EditProfile.textDark)),
            Row(
              children: [
                Text(vm.selectedGender, style: GoogleFonts.poppins(color: EditProfile.textLight)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String fieldName, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $fieldName", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: fieldName,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: GoogleFonts.poppins(color: EditProfile.textLight))),
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Save", style: GoogleFonts.poppins(color: EditProfile.primaryGreen, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _showGenderDialog(BuildContext context, EditProfileViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Gender", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: vm.genders.length,
            itemBuilder: (context, index) {
              final gender = vm.genders[index];
              return RadioListTile(
                title: Text(gender, style: GoogleFonts.poppins()),
                value: gender,
                groupValue: vm.selectedGender,
                activeColor: EditProfile.primaryGreen,
                onChanged: (value) {
                  vm.setGender(value!);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
