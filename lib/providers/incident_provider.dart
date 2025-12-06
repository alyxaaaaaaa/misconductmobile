import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import 'package:misconductmobile/variables.dart';

class IncidentProvider with ChangeNotifier {
  List<Incident> incidents = [];
  List<Student> students = [];
  bool isLoading = false;

  bool get loading => isLoading;

  final IncidentService _service = IncidentService();

  // -----------------------------
  // Load Incidents
  // -----------------------------
  Future<void> loadIncidents() async {
    isLoading = true;
    notifyListeners();

    try {
      incidents = await _service.fetchIncidents(); 
    } catch (e) {
      print("Error loading incidents: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // -----------------------------
  // Create Incident
  // -----------------------------
  Future<Map<String, dynamic>> createIncident(Incident incident) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _service.createIncident(incident); 
      await loadIncidents(); 
      isLoading = false;
      notifyListeners();
      return response; 
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // -----------------------------
  // Update Incident
  // -----------------------------
  Future<void> updateIncident(Incident incident) async {
    await _service.updateIncident(incident);
    await loadIncidents();
  }

  // -----------------------------
  // Delete Incident
  // -----------------------------
  Future<void> deleteIncident(int id) async {
    await _service.deleteIncident(id);
    await loadIncidents();
  }

  // -----------------------------
  // Fetch Students for Dropdown
  // -----------------------------
  Future<void> loadStudents() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/students/dropdown'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body)['students'];
        students = data.map((e) => Student.fromJson(e)).toList();
        notifyListeners();
      } else {
        throw Exception("Failed to load students");
      }
    } catch (e) {
      print("Error fetching students: $e");
      throw Exception("Failed to fetch students: $e");
    }
  }

  // -----------------------------
  // Get Student Details by ID
  // -----------------------------
  Student? getStudentById(String id) {
    try {
      return students.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
