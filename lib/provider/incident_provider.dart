// incident_provider.dart

import 'package:flutter/foundation.dart';
import 'package:misconductmobile/models/incident.dart';
import 'package:misconductmobile/services/api_service.dart';

class IncidentProvider extends ChangeNotifier {
  // --- STATE ---
  List<Incident> _incidents = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Incident> get incidents => _incidents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- ACTIONS ---

  // Fetches incidents and updates the state
  Future<void> fetchIncidents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify listeners that loading has started

    try {
      final fetchedIncidents = await ApiService.fetchUserIncidents();
      _incidents = fetchedIncidents;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load incidents: $e';
      if (kDebugMode) {
        print(_errorMessage);
      }
      _incidents = []; // Clear old data on error
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners when loading is complete (success or failure)
    }
  }

  // You would call this method from your submission screen
  // after a successful incident submission.
  Future<void> reloadIncidentsAfterSubmission() async {
    await fetchIncidents();
  }
}