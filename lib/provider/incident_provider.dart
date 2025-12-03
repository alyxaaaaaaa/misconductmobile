import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';

class IncidentProvider with ChangeNotifier {
  List<Incident> incidents = [];
  bool isLoading = false;

  final IncidentService _service = IncidentService();

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

  Future<void> updateIncident(Incident incident) async {
    await _service.updateIncident(incident);
    await loadIncidents();
  }

  Future<void> deleteIncident(int id) async {
    await _service.deleteIncident(id);
    await loadIncidents();
  }
}