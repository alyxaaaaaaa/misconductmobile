import 'package:flutter/material.dart';
import 'package:misconductmobile/screens/ProfilePage.dart'; 
import 'package:misconductmobile/screens/AddIncidentPage.dart'; // The ADD form
import 'package:misconductmobile/screens/IncidentsLists.dart'; // The HOME list view

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  int _currentIndex = 0;
  
  static const primaryColor = Color(0xFF2E7D32);

  // Screens for the persistent tabs (List and Profile only)
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens
    _screens = [
      const IncidentsList(), // 0: Home Tab -> Incidents List
      const ProfileScreen(), // 1: Profile Tab
    ];
  }

  void _navigateToAddIncidentScreen() {
    // Navigates to the form.
    Navigator.push(
      context,
      // NOTE: This should likely be named 'IncidentsPage' (the form you showed earlier)
      MaterialPageRoute(builder: (_) => const IncidentsPage()), 
    );
    // REMOVE the .then((result) {...}) callback entirely.
    // Why? Because when the AddIncidentPage successfully calls 
    // `incidentProvider.createIncident(incident)`, the provider automatically
    // calls `loadIncidents()` and `notifyListeners()`. The IncidentsList
    // widget listens to those changes and updates itself automatically.
  }

  void _onTabTapped(int index) {
    if (index == 1) { // Target the 'Add Incident' item (index 1)
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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex == 0 ? 0 : 2, 
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
          // Navigation Action button (Index 1)
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