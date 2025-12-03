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

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();

  XFile? _profileImageXFile; 
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, 
    );

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
        final User? newUserData = await ApiService.updateUserProfile(
            _nameController.text,
            _emailController.text,
            _profileImageXFile, 
        );

        if (newUserData != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
            );

            setState(() {
                _profileImageXFile = null;
            });

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

  void _showChangePasswordDialog() {

  }
  Future<void> _changePassword() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    setState(() => _isLoading = false);
    Navigator.pop(context, true); 
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    ImageProvider? getProfileImageProvider() {
      if (_profileImageXFile != null) {
        return FileImage(File(_profileImageXFile!.path));
      } else if (widget.initialUser.profilePicturePath.isNotEmpty) {
        return NetworkImage(widget.initialUser.profilePicturePath);
      }
      return null;
    }

    final bool isImageSet = getProfileImageProvider() != null; 

    return Scaffold(
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
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        backgroundImage: getProfileImageProvider(),
                        
                        child: isImageSet
                            ? null
                            : const Icon(Icons.camera_alt, size: 40, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                       controller: _emailController,
                       decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                       keyboardType: TextInputType.emailAddress,
                       style: const TextStyle(fontSize: 18),
                       validator: (value) => !value!.contains('@') ? 'Enter a valid email' : null,
                    ),
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