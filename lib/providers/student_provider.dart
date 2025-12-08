import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../variables.dart';
import '../services/api_service.dart'; 

class StudentProvider extends ChangeNotifier {
  final String apiBaseUrl = baseUrl;

  List<Student> _students = [];
  bool _loading = false;
  String? _errorMessage;

  List<Student> get students => _students;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStudentsForDropdown() async {
    if (_loading) return;
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = ApiService.getAuthToken() ?? '';

      if (token.isEmpty) {
        _errorMessage = "Token is missing. Please log in again.";
        _students = [];
        notifyListeners();
        return;
      }

      final url = Uri.parse('$apiBaseUrl/students/dropdown');
      final resp = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (resp.statusCode == 200) {
        final dynamic data = jsonDecode(resp.body);
        final List<dynamic> payload = data is List ? data : (data['students'] ?? []);
        _students = payload.map((e) => Student.fromJson(e)).toList();
        notifyListeners();
      } else if (resp.statusCode == 401) {
        _errorMessage = '401 Unauthorized. Please log in again.';
        _students = [];
        notifyListeners();
      } else {
        _errorMessage = 'Failed to load students: ${resp.statusCode}';
        _students = [];
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Error fetching students: $e";
      _students = [];
      notifyListeners();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
