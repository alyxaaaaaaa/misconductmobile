// IncidentProvider.dart

import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';

class IncidentProvider with ChangeNotifier {
  List<Incident> incidents = [];
  bool isLoading = false;

  final IncidentService _service = IncidentService();

  Future<void> loadIncidents() async { // Made return type explicit
    isLoading = true;
    notifyListeners();

    try {
      // 🎯 RENAME 1: Use the new consolidated fetchIncidents()
      incidents = await _service.fetchIncidents(); 
    } catch (e) {
      print("Error loading incidents: $e");
      // Optionally handle error state here
    }
    
    isLoading = false;
    notifyListeners();
  }

  /// CREATE with return value (works with recommendation popup)
  Future<Map<String, dynamic>> createIncident(Incident incident) async {
    isLoading = true;
    notifyListeners();

    try {
      // 🎯 RENAME 2: Use the new clean createIncident()
      final response = await _service.createIncident(incident); 

      // Reload the list to include the new incident
      await loadIncidents(); 
      isLoading = false;
      notifyListeners();

      return response; // <-- RETURN to UI
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateIncident(Incident incident) async {
    await _service.updateIncident(incident);
    await loadIncidents();
  }

  Future<void> deleteIncident(int id) async {
    await _service.deleteIncident(id);
    await loadIncidents();
  }
}