import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int? _id;
  String? _name; 
  String? _email;

  int? get id => _id;
  String? get name => _name; 
  String? get email => _email;

  get role => null;

  void setUser(Map<String, dynamic> user) {
    _id = user['id'];
    _name = user['name']; 
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