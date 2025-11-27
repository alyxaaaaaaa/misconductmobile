import 'package:flutter/material.dart';
import 'package:misconductmobile/screens/LoginPage.dart'; 
import 'package:misconductmobile/models/user.dart';
import 'package:misconductmobile/services/api_service.dart'; 
import 'package:misconductmobile/screens/EditProfileScreen.dart'; 
import 'package:misconductmobile/variables.dart'; 

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

  void _navigateToEditProfile() {
    if (_user == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(initialUser: _user!), 
      ),
    ).then((result) {
      // Receive the User object directly after successful update
      if (result is User) {
        setState(() {
          // Update local state immediately with the new User object (which contains the new image URL)
          _user = result;
        });
      }
      else if (result == true) { 
        _loadUserData(); 
      }
    });
  }

  Future<void> _confirmLogout() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Perform logout logic here (e.g., clearing tokens)
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()), 
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Color(0xFFD32F2F))),
          ),
        ],
      ),
    );
  }

  Widget _profileInfoRow(IconData icon, String label, String value) {
    final displayValue = (value == 'N/A' || value.isEmpty) ? 'Data not available' : value;
    final valueColor = (value == 'N/A' || value.isEmpty) ? Colors.red.shade400 : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(displayValue, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: valueColor)),
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
    final bool isUserDataValid = _user != null && (_user!.fullName) != 'N/A';
    
    final String? profileImagePath = _user?.profilePicturePath;
    final bool hasProfilePicture = profileImagePath != null && profileImagePath.isNotEmpty;

    // --- FIX 1: Assemble the complete, cache-busting URL ---
    String? cacheBustingUrl;
    if (hasProfilePicture) {
      String fullPath = profileImagePath!;

      // 🔑 Use the imported API_BASE_URL constant from variables.dart
      if (!fullPath.startsWith('http')) {
        fullPath = baseUrl + fullPath; // Assumes your constant is named API_BASE_URL
      }
      
      // Append the cache-buster to force refresh
      cacheBustingUrl = fullPath + '?v=${DateTime.now().millisecondsSinceEpoch}';
    }

    final ImageProvider? avatarImage = cacheBustingUrl != null 
      ? NetworkImage(cacheBustingUrl) 
      : null;

    // --- FIX 2: Use a unique key to force the CircleAvatar to rebuild ---
    final Key avatarKey = hasProfilePicture 
      ? ValueKey('profile_image_$profileImagePath') 
      : const ValueKey('default_avatar'); 


    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: const [], 
      ),
      
      body: Center(
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
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile Avatar
                          GestureDetector(
                            onTap: _navigateToEditProfile, 
                            child: CircleAvatar(
                              key: avatarKey, // 🔑 The key forces a redraw
                              radius: 50,
                              backgroundColor: primaryColor.withOpacity(0.1),
                              backgroundImage: avatarImage, 
                              child: hasProfilePicture
                                  ? null 
                                  : Icon(
                                        isUserDataValid ? Icons.person_rounded : Icons.error_outline,
                                        size: 60,
                                        color: isUserDataValid ? primaryColor : Colors.red,
                                  ),
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
                              child: Text("User data is currently unavailable...", textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
                            )
                          ],
                          
                          const SizedBox(height: 24),

                          // Edit Profile Button
                          if (isUserDataValid && !_isLoading)
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _navigateToEditProfile,
                                    icon: const Icon(Icons.edit, color: Colors.white),
                                    label: const Text("EDIT PROFILE", style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor, 
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16), 
                              ],
                            ),
                          
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 5,
                              ),
                            ),
                          )
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}