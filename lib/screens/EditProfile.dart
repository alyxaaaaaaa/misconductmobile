import 'package:flutter/material.dart';
import 'package:misconductmobile/services/api_service.dart';
import 'package:misconductmobile/models/user.dart';

class EditProfileScreen extends StatefulWidget {
  final User initialUser;

  const EditProfileScreen({super.key, required this.initialUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const primaryColor = Color(0xFF2E7D32);
  static const Color lightGreenBackground = Color(0xFFE8F5E9); // Light green background

  final _profileFormKey = GlobalKey<FormState>(); 
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  // NOTE: Password fields are still disposed, but currently not used in the UI/logic
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  // XFile? _profileImageXFile; // REMOVED: No longer needed for Add Photo functionality
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialUser.fullName;
    _emailController.text = widget.initialUser.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  // REMOVED: _pickImage method is no longer needed

  Future<void> _updateProfile() async {
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
        final User? newUserData = await ApiService.updateUserProfile(
            _nameController.text,
            _emailController.text,
            null, // Pass null as there is no image to update
        );

        if (newUserData != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
            );

            // REMOVED: _profileImageXFile = null;

            Navigator.pop(context, newUserData); 

        } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to update profile.')),
            );
        }
    } catch (e) {
        if (mounted) {
            String message = 'Error updating profile.';
            if (e is Exception && e.toString().contains('Validation failed')) {
                message = e.toString().substring(e.toString().indexOf(':') + 1).trim();
            }
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
            );
        }
    } finally {
        setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // REMOVED: getProfileImageProvider function is no longer needed
    // REMOVED: isImageSet bool is no longer needed

    return Scaffold(
      backgroundColor: lightGreenBackground, // APPLYING lightGreenBackground
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: width * 0.92,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 8)),
                ],
              ),
              child: Form(
                key: _profileFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // === MODIFICATION 2: PROFILE PHOTO WIDGET MODIFIED ===
                    // Kept the circle avatar but removed the GestureDetector and image logic
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      // Only display the network image if a path exists
                      backgroundImage: widget.initialUser.profilePicturePath.isNotEmpty
                          ? NetworkImage(widget.initialUser.profilePicturePath)
                          : null,
                      child: widget.initialUser.profilePicturePath.isEmpty
                          ? const Icon(Icons.person, size: 60, color: primaryColor)
                          : null,
                    ),
                    // ====================================================
                    const SizedBox(height: 20),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
                    ),
                    const SizedBox(height: 16),

                    // === MODIFICATION 3: EMAIL FIELD MADE NON-EDITABLE (ENABLED: FALSE) ===
                    TextFormField(
                       controller: _emailController,
                       decoration: InputDecoration(
                         labelText: 'Email (Not editable)', 
                         prefixIcon: const Icon(Icons.email),
                         // Add a subtle color to indicate it's disabled
                         fillColor: lightGreenBackground.withOpacity(0.5), 
                         filled: true,
                       ),
                       keyboardType: TextInputType.emailAddress,
                       style: const TextStyle(fontSize: 18, color: Colors.grey),
                       enabled: false, // Prevents editing
                       // No need for validator since it can't be changed
                    ),
                    // ====================================================================
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Save Changes", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}