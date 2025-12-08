import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../models/incident.dart';
import '../services/incident_service.dart';

String _formatTimeForApi(String timeString) {
  if (timeString.contains(':')) {
    try {
      final parts = timeString.split(':');
      final hour = parts[0].padLeft(2, '0');
      final minute = (parts.length > 1 ? parts[1] : '00').padLeft(2, '0');
      return '$hour:$minute'; 
    } catch (e) {
      return timeString; 
    }
  }
  return timeString;
}

class IncidentProvider with ChangeNotifier {
  List<Incident> incidents = [];
  bool isLoading = false;

  int _misconductThisMonthCount = 0; 
  int get misconductThisMonthCount => _misconductThisMonthCount;
  
  final IncidentService _service = IncidentService();

  bool get loading => isLoading;

  int get overallIncidentsCount => incidents.length; 

  void _calculateDashboardMetrics() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    _misconductThisMonthCount = incidents.where((incident) {
      final incidentDate = DateTime.tryParse(incident.dateOfIncident);
      return incidentDate != null && 
             (incidentDate.isAfter(startOfMonth) || incidentDate.isAtSameMomentAs(startOfMonth));
    }).length;
  }

  Future<void> loadIncidents() async {
    isLoading = true;
    notifyListeners();

    try {
      final allIncidents = await _service.fetchIncidents();

      incidents = allIncidents.where((i) => i.status != 'Deleted').toList();
      
      _calculateDashboardMetrics();

    } catch (e) {
      print("Error loading incidents: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteIncident(Incident incidentToDelete) async {
    final softDeletedIncident = incidentToDelete.copyWith(
      timeOfIncident: _formatTimeForApi(incidentToDelete.timeOfIncident),
      status: 'Deleted',
    );

    await _service.updateIncident(softDeletedIncident);

    await loadIncidents(); 
  }

  Future<Map<String, dynamic>> createIncident(Incident incident) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _service.createIncident(incident);
      await loadIncidents();
      return response;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateIncident(Incident incident) async {
    await _service.updateIncident(incident);
    await loadIncidents();
  }

  Future<Incident> fetchIncidentById(int id) async {
    try {
      final fetchedIncident = await _service.fetchIncidentById(id);
      return fetchedIncident;
    } catch (e) {
      rethrow; 
    }
  }
}