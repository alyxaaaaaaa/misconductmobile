import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../models/incident.dart';
import '../services/incident_service.dart';

/// Helper to ensure time is strictly in HH:MM format (truncates seconds if present)
String _formatTimeForApi(String timeString) {
  if (timeString.contains(':')) {
    try {
      final parts = timeString.split(':');
      final hour = parts[0].padLeft(2, '0');
      final minute = (parts.length > 1 ? parts[1] : '00').padLeft(2, '0');
      return '$hour:$minute'; // Returns HH:MM
    } catch (e) {
      return timeString; 
    }
  }
  return timeString;
}

class IncidentProvider with ChangeNotifier {
  // -------------------------------------------------------------
  // State Variables
  // -------------------------------------------------------------
  List<Incident> incidents = [];
  bool isLoading = false;

  // 🎯 Dashboard State Variables
  int _misconductThisMonthCount = 0; 
  int get misconductThisMonthCount => _misconductThisMonthCount;
  
  final IncidentService _service = IncidentService();

  bool get loading => isLoading;

  // Calculated property for Dashboard (Total Misconduct)
  int get overallIncidentsCount => incidents.length; 

  // -------------------------------------------------------------
  // 🎯 Dashboard Metric Calculation Method
  // -------------------------------------------------------------
  /// Calculates the "Misconduct This Month" count from the currently loaded list.
  void _calculateDashboardMetrics() {
    final now = DateTime.now();
    // Get the first day of the current month
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    // Filter incidents that occurred this month and are not deleted
    _misconductThisMonthCount = incidents.where((incident) {
      final incidentDate = DateTime.tryParse(incident.dateOfIncident);
      // We check that the date is on or after the first of the month
      return incidentDate != null && 
             (incidentDate.isAfter(startOfMonth) || incidentDate.isAtSameMomentAs(startOfMonth));
    }).length;
    // Note: notifyListeners() will be handled by the calling function (loadIncidents)
  }


  // -------------------------------------------------------------
  // Load all incidents & Calculate Metrics
  // -------------------------------------------------------------
  Future<void> loadIncidents() async {
    isLoading = true;
    notifyListeners();

    try {
      final allIncidents = await _service.fetchIncidents();

      // Filter out soft-deleted incidents
      incidents = allIncidents.where((i) => i.status != 'Deleted').toList();
      
      // 🎯 CRITICAL: Calculate new dashboard metrics after list loads
      _calculateDashboardMetrics();

    } catch (e) {
      print("Error loading incidents: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------------
  // Soft-delete an incident (Calls loadIncidents for refresh)
  // -------------------------------------------------------------
  Future<void> deleteIncident(Incident incidentToDelete) async {
    final softDeletedIncident = incidentToDelete.copyWith(
      timeOfIncident: _formatTimeForApi(incidentToDelete.timeOfIncident),
      status: 'Deleted', // Mark as deleted
    );

    // 1. Update the incident on the backend
    await _service.updateIncident(softDeletedIncident);

    // 2. Reload all data, which triggers metric recalculation and notification
    await loadIncidents(); 
  }

  // -------------------------------------------------------------
  // Create, Update, Fetch Single Incident (remaining methods)
  // -------------------------------------------------------------

  Future<Map<String, dynamic>> createIncident(Incident incident) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _service.createIncident(incident);
      // Refresh the list AND recalculate dashboard metrics after creation
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
    // Refresh the list and metrics to reflect changes
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