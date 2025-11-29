// main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:misconductmobile/provider/user_provider.dart';
import 'package:misconductmobile/provider/incident_provider.dart'; 
import 'package:misconductmobile/screens/LoginPage.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Existing provider
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // 🎯 ADD THE NEW INCIDENT PROVIDER HERE:
        ChangeNotifierProvider(create: (_) => IncidentProvider()), 
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
      // Note: You might want to use a Consumer or Provider.of in the future
      // to determine the home screen based on UserProvider (e.g., if logged in).
      home: LoginScreen(), 
    );
  }
}