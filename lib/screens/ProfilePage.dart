// File: ProfileScreen.dart

import 'package:flutter/material.dart';
import 'package:misconductmobile/screens/LoginPage.dart'; 
import 'package:misconductmobile/models/user.dart';
import 'package:misconductmobile/services/api_service.dart';
import 'package:misconductmobile/screens/EditProfileScreen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const primaryColor = Color(0xFF2E7D32);
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Called initially and after returning from EditProfileScreen
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await ApiService.fetchCurrentUser(); 
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _errorMessage = "Authentication failed or profile data not found.";
        _isLoading = false;
      });
    }
  }

  // 🎯 Navigation to Edit Profile screen
  void _navigateToEditProfile() {
    if (_user == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(initialUser: _user!), 
      ),
    ).then((result) {
      // Refresh the profile data when returning if the result flag is true
      if (result == true) {
        _loadUserData(); 
      }
    });
  }


  Future<void> _confirmLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out of your account?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: primaryColor)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      ApiService.setAuthToken(null);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logged out successfully!")),
      );
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()), 
        (Route<dynamic> route) => false,
      );
    }
  }

  Widget _profileInfoRow(IconData icon, String label, String value) {
    final displayValue = (value == 'N/A' || value.isEmpty) ? 'Data not available' : value;
    final valueColor = (value == 'N/A' || value.isEmpty) ? Colors.red.shade400 : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isUserDataValid = _user != null && _user!.fullName != 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // 🎯 EDIT BUTTON: Routes to the EditProfileScreen
          if (isUserDataValid && !_isLoading)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _navigateToEditProfile,
            ),
        ],
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
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    )
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Profile Avatar
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: primaryColor.withOpacity(0.1),
                              child: Icon(
                                isUserDataValid ? Icons.person_rounded : Icons.error_outline,
                                size: 60,
                                color: isUserDataValid ? primaryColor : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // User Full Name (Headline)
                            Text(
                              _user?.fullName ?? 'Profile Missing',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Divider(color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            
                            if (_user != null) ...[
                              _profileInfoRow(Icons.email, "Email Address", _user!.email),
                            ] else ...[
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  "User data is currently unavailable. Please contact support or try logging out and back in.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                                ),
                              )
                            ],
                            
                            const SizedBox(height: 24),
                            
                            // Logout Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _confirmLogout,
                                icon: const Icon(Icons.logout, color: Colors.white),
                                label: const Text("LOGOUT", style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD32F2F),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                              ),
                            )
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }
}