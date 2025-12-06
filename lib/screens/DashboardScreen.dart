import 'package:flutter/material.dart';
import 'package:misconductmobile/screens/ProfilePage.dart';
import 'package:misconductmobile/screens/AddIncident.dart';
import 'package:misconductmobile/screens/IncidentsLists.dart';
import 'package:misconductmobile/screens/Dashboard.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  static const primaryColor = Color(0xFF2E7D32);

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
       DashboardPageContent(),
      const IncidentsList(),
      const ProfileScreen(),
    ];
  }

  void _navigateToAddIncidentScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddIncident()),
    );
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      _navigateToAddIncidentScreen();
    } else {
      int newScreenIndex;
      if (index == 0) {
        newScreenIndex = 0;
      } else if (index == 1) {
        newScreenIndex = 1;
      } else {
        newScreenIndex = 2;
      }

      setState(() {
        _currentIndex = newScreenIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Dashboard'),
      //   backgroundColor: primaryColor,
      //   foregroundColor: Colors.white,
      // ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex == 0 ? 0 : (_currentIndex == 1 ? 1 : 3),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Incidents List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 25),
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