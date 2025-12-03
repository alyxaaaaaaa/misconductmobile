import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:misconductmobile/variables.dart';
import 'package:misconductmobile/models/incident.dart';
import 'api_service.dart'; 

class IncidentService {
  final String _incidentBaseUrl = '$baseUrl/incidents';

  Map<String, String> _getAuthHeaders() {
    final token = ApiService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> createIncident(Incident incident) async {
    try {
      final response = await http.post(
        Uri.parse(_incidentBaseUrl),
        headers: _getAuthHeaders(),
        body: jsonEncode(incident.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final Incident createdIncident = Incident.fromJson(data['incident']);

        return {
          "incident": createdIncident,
          "recommendation": data['recommendation'] ?? "",
        };
      } 
      else if (response.statusCode == 422) {
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

  Future<List<Incident>> fetchIncidents() async {
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

  Future<void> updateIncident(Incident incident) async {
    final response = await http.put(
      Uri.parse("$_incidentBaseUrl/${incident.incidentId}"),
      headers: _getAuthHeaders(), 
      body: jsonEncode(incident.toJson()),
    );

    if (response.statusCode != 200) {
       throw Exception("Failed to update incident: ${response.statusCode}");
    }
    
  }
  
  Future<void> updateActionTaken(int incidentId, String action) async {
    try {
      final response = await http.patch(
        Uri.parse('$_incidentBaseUrl/$incidentId/action'),
        headers: _getAuthHeaders(), 
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

  Future<void> deleteIncident(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$_incidentBaseUrl/$id"),
        headers: _getAuthHeaders(), 
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to delete incident: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
}