// lib/services/incident_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
// Removed unnecessary SharedPreferences import
// import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:misconductmobile/variables.dart'; // Contains baseUrl
import 'package:misconductmobile/models/incident.dart';
import 'api_service.dart'; // Import the central token management

class IncidentService {
  final String _incidentBaseUrl = '$baseUrl/incidents';

  // Helper to get authenticated headers (This is the single source of truth for the token)
  Map<String, String> _getAuthHeaders() {
    // ApiService must be responsible for retrieving and storing the token (e.g., from SharedPreferences).
    final token = ApiService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      // Only include Authorization header if a token exists
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. CREATE INCIDENT (Consolidated from the two previous create methods)
  // This method is designed to return the created Incident object and recommendation.
  Future<Map<String, dynamic>> createIncident(Incident incident) async {
    try {
      final response = await http.post(
        Uri.parse(_incidentBaseUrl),
        headers: _getAuthHeaders(), // <-- Using the clean helper
        body: jsonEncode(incident.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Convert returned incident JSON → Incident object
        final Incident createdIncident = Incident.fromJson(data['incident']);

        return {
          "incident": createdIncident,
          "recommendation": data['recommendation'] ?? "",
        };
      } 
      else if (response.statusCode == 422) {
         // Handle validation errors
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['errors']?.toString() ?? 'Validation failed.');
      }
      else {
        print("Create Incident ERROR: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to create incident: ${response.statusCode}");
      }
    } catch (e) {
      print("Error submitting incident: $e");
      rethrow;
    }
  }

  // 2. FETCH INCIDENTS (Consolidated from fetchUserIncidents, fetchIncidentsByRole, and getIncidents)
  /// Fetches incidents based on the authenticated user's role/token.
  Future<List<Incident>> fetchIncidents() async {
    final uri = Uri.parse(_incidentBaseUrl); 
    
    try {
      final response = await http.get(
        uri,
        headers: _getAuthHeaders(), // <-- Using the clean helper
      );

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);
        
        List data = (responseBody is Map && responseBody.containsKey('data')) 
                      ? responseBody['data'] as List 
                      : responseBody as List;
        
        return data.map((i) => Incident.fromJson(i as Map<String, dynamic>)).toList();
      } else {
        throw Exception("Failed to load incidents: Server returned ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  // 3. UPDATE FULL INCIDENT (Corrected to use _getAuthHeaders and throw on failure)
  Future<void> updateIncident(Incident incident) async {
    final response = await http.put(
      Uri.parse("$_incidentBaseUrl/${incident.incidentId}"),
      headers: _getAuthHeaders(), // <-- Using the clean helper
      body: jsonEncode(incident.toJson()),
    );

    if (response.statusCode != 200) {
       throw Exception("Failed to update incident: ${response.statusCode}");
    }
    // No need to return bool, simply complete the Future successfully
  }
  
  // 4. UPDATE DISCIPLINARY ACTION TAKEN
  Future<void> updateActionTaken(int incidentId, String action) async {
    try {
      final response = await http.patch(
        Uri.parse('$_incidentBaseUrl/$incidentId/action'),
        headers: _getAuthHeaders(), // <-- Using the clean helper
        body: jsonEncode({'action_taken': action}),
      );
      if (response.statusCode != 200) {
          throw Exception("Failed to update action taken: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating action taken: $e");
      rethrow;
    }
  }

  // 5. DELETE INCIDENT (Corrected to use _getAuthHeaders and throw on failure)
  Future<void> deleteIncident(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$_incidentBaseUrl/$id"),
        headers: _getAuthHeaders(), // <-- Using the clean helper
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to delete incident: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
}