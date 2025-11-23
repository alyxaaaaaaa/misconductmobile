import 'package:flutter/material.dart';
import 'package:misconductmobile/screens/IncidentsPage.dart'; 
import 'package:misconductmobile/screens/ProfilePage.dart'; 


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  int _currentIndex = 0;
  
  static const primaryColor = Color(0xFF2E7D32);

  final List<Widget> _screens = [
    
    const Center(
      child: Text(
        'Home Screen - Overview of incidents', 
        style: TextStyle(fontSize: 24, color: primaryColor, fontWeight: FontWeight.bold)
      ),
    ),
    
    const ProfileScreen(), 
  ];

  void _navigateToAddIncidentScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddIncidentScreen()),
    );
  }

  void _onTabTapped(int index) {
    if (index == 1) { 
      _navigateToAddIncidentScreen();
    } else if (index == 0) {
      setState(() {
        _currentIndex = 0; 
      });
    } else if (index == 2) {
      setState(() {
        _currentIndex = 1; 
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        // We initialize currentIndex to 0 (Home)
        currentIndex: _currentIndex == 0 ? 0 : 2, // Highlight Home or Profile based on _currentIndex (0 or 1)
        onTap: _onTabTapped, 
        
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          // 🎯 This is the Navigation Action button
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40), 
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