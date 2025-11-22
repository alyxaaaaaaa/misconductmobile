import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int? _id;
  String? _name;
  String? _email;

  int? get id => _id;
  String? get name => _name;
  String? get email => _email;

  void setUser(Map<String, dynamic> user) {
    // ⚠️ UPDATE: Use 'fullName' key instead of 'name'
    _id = user['id'];
    _name = user['fullName']; // Key updated to match the registration field
    _email = user['email'];
    notifyListeners();
  }

  void logout() {
    _id = null;
    _name = null;
    _email = null;
    notifyListeners();
  }
}