// File: EditProfileScreen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; 
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
  final _profileFormKey = GlobalKey<FormState>(); 
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  // Password fields for dialog
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();

  // Stores the selected image file path
  XFile? _profileImageXFile; 
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialUser.fullName;
    _emailController.text = widget.initialUser.email;
    // You would load the existing profile picture URL here if available
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImageXFile = image;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final success = await ApiService.updateUserProfile(
        _nameController.text,
        _emailController.text,
        _profileImageXFile != null ? File(_profileImageXFile!.path) : null,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        // Signal success back to the ProfileScreen to trigger a refresh
        Navigator.pop(context, true); 
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Part of the _EditProfileScreenState class

void _showChangePasswordDialog() {
  // Use three separate state variables to control visibility for each field
  bool currentPasswordVisible = false;
  bool newPasswordVisible = false;
  bool confirmPasswordVisible = false;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Change Password'),
        // 🎯 Use StatefulBuilder to manage the visibility state locally within the dialog
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Form(
              key: _passwordFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Current Password Field ---
                  TextFormField(
                    controller: _currentPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      // 🎯 Add the toggle icon
                      suffixIcon: IconButton(
                        icon: Icon(
                          currentPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            currentPasswordVisible = !currentPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !currentPasswordVisible, // Use the state variable
                    validator: (value) => value!.isEmpty ? 'Please enter current password' : null,
                  ),

                  // --- New Password Field ---
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      // 🎯 Add the toggle icon
                      suffixIcon: IconButton(
                        icon: Icon(
                          newPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            newPasswordVisible = !newPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !newPasswordVisible, // Use the state variable
                    validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
                  ),

                  // --- Confirm New Password Field ---
                  TextFormField(
                    controller: _confirmNewPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      // 🎯 Add the toggle icon
                      suffixIcon: IconButton(
                        icon: Icon(
                          confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            confirmPasswordVisible = !confirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !confirmPasswordVisible, // Use the state variable
                    validator: (value) => value != _newPasswordController.text ? 'Passwords do not match' : null,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _changePassword,
            child: _isLoading ? const CircularProgressIndicator() : const Text('Change'),
          ),
        ],
      );
    },
  );
}

// ... (The rest of the _changePassword function remains unchanged)

  Future<void> _changePassword() async {
     if (!(_passwordFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
        final success = await ApiService.changePassword(
          _currentPasswordController.text,
          _newPasswordController.text,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully!')),
          );
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmNewPasswordController.clear();
          Navigator.pop(context); // Close the dialog
        } else if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to change password. Check your current password.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error changing password: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), primaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
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
                    // Profile Picture Editor
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        // Display logic: show selected image if available, else show the user's existing image (URL)
                        // If running on web and using FileImage(dart:io.File) causes errors, you might need to adjust this display logic.
                        backgroundImage: _profileImageXFile != null 
                             ? FileImage(File(_profileImageXFile!.path)) as ImageProvider // Display selected image 
                             // Placeholder for displaying existing profile image URL, adjust based on your User model
                             : null, 
                        child: _profileImageXFile == null
                            ? const Icon(Icons.camera_alt, size: 40, color: primaryColor)
                            : null, // Icon removed if a new picture is selected
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 18),
                      validator: (value) => !value!.contains('@') ? 'Enter a valid email' : null,
                    ),
                    const SizedBox(height: 30),

                    // Change Password Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _showChangePasswordDialog,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Change Password", style: TextStyle(fontSize: 18, color: primaryColor)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
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