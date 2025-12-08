import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:misconductmobile/providers/student_provider.dart'; 
import 'package:misconductmobile/providers/user_provider.dart';
import 'package:misconductmobile/providers/incident_provider.dart'; 
import 'package:misconductmobile/screens/LoginScreen.dart';
import 'package:misconductmobile/providers/dashboard_stats_provider.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => IncidentProvider()), 
        ChangeNotifierProvider(create: (_) => DashboardStatsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMRMS',
      home: LoginScreen(), 
    );
  }
}