// lib/services/incident_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:misconductmobile/variables.dart'; // Contains baseUrl
import 'package:misconductmobile/models/incident.dart';
import 'api_service.dart'; // Import the central token management

class IncidentService {
  final String _incidentBaseUrl = '$baseUrl/incidents';

  // Helper to get authenticated headers
  Map<String, String> _getAuthHeaders() {
    final token = ApiService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. CREATE INCIDENT (MODIFIED FOR OPTIMIZATION FEATURE)
  // Returns a Map containing the created Incident object and the system's recommendation.
  Future<Map<String, dynamic>> submitIncident(Incident incident) async {
    try {
      final response = await http.post(
        Uri.parse(_incidentBaseUrl),
        headers: _getAuthHeaders(),
        body: jsonEncode(incident.toJson()),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        
        // Return both the Incident object and the recommendation string
        return {
          'incident': Incident.fromJson(responseBody['incident']),
          'recommendation': responseBody['recommendation'] as String,
        };
      } else if (response.statusCode == 422) {
        // Validation error
        throw Exception(jsonDecode(response.body)['errors'] ?? 'Validation failed.');
      } else {
        throw Exception('Failed to file incident: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error submitting incident: $e");
      rethrow;
    }
  }

  // 2. FETCH ALL INCIDENTS
  Future<List<Incident>> fetchAllIncidents() async {
    final uri = Uri.parse(_incidentBaseUrl);
    try {
      final response = await http.get(
        uri,
        headers: _getAuthHeaders(),
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

  // 3. GET SINGLE INCIDENT
  Future<Incident?> getIncident(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$_incidentBaseUrl/$id"),
        headers: _getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        return Incident.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // 4. UPDATE FULL INCIDENT
  Future<bool> updateIncident(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse("$_incidentBaseUrl/$id"),
        headers: _getAuthHeaders(),
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // 5. UPDATE DISCIPLINARY ACTION TAKEN (NEW PATCH ENDPOINT)
  Future<bool> updateActionTaken(int incidentId, String action) async {
    try {
      final response = await http.patch(
        Uri.parse('$_incidentBaseUrl/$incidentId/action'),
        headers: _getAuthHeaders(),
        body: jsonEncode({'action_taken': action}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error updating action taken: $e");
      return false;
    }
  }

  // 6. DELETE INCIDENT
  Future<bool> deleteIncident(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$_incidentBaseUrl/$id"),
        headers: _getAuthHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}