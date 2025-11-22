import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:misconductmobile/provider/user_provider.dart';
import 'package:misconductmobile/screens/LoginPage.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
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