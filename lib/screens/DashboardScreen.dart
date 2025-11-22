import 'package:flutter/material.dart';
// Note: Assuming AddIncidentScreen is accessible from this import path or another local path
import 'package:misconductmobile/screens/IncidentsPage.dart'; 
// Corrected import path name to match the ProfileScreen class name
import 'package:misconductmobile/screens/ProfilePage.dart'; 

// Assuming the class AddIncidentScreen is defined and available (e.g., in a separate file or IncidentsPage.dart)
// If it's in a separate file named AddIncidentScreen.dart, you might need:
// import 'AddIncidentScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  
  // Define the primary color to ensure theme consistency
  static const primaryColor = Color(0xFF2E7D32);

  // Screens for each tab
  final List<Widget> _screens = [
    // 0: Home Tab (Placeholder)
    const Center(
      child: Text(
        'Home Screen - Overview of incidents', 
        style: TextStyle(fontSize: 24, color: primaryColor, fontWeight: FontWeight.bold)
      ),
    ),
    
    // 1: Add Incident Tab - Using the actual screen
    // Note: The screens below already have their own AppBars, which is why 
    // the main Dashboard Scaffold does not need one.
    const AddIncidentScreen(), 
    
    // 2: Profile Tab - Using the actual screen
    const ProfileScreen(), 
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body displays the currently selected screen
      body: _screens[_currentIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        // Style properties updated to match the green theme
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed, // Use fixed type for consistent styling
        
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40), // Large icon for the main action
            label: 'Add Incident',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}