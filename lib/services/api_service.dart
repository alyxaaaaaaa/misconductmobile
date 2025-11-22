import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:misconductmobile/variables.dart';
import 'package:misconductmobile/models/incident.dart';
import 'package:misconductmobile/models/user.dart'; // Import the User model

class ApiService {

  // Placeholder for storing the authentication token. 
  // In a real app, you would use a secure storage solution like flutter_secure_storage.
  static String? _authToken;

  // Method to store the token upon successful login
  static void setAuthToken(String? token) {
    _authToken = token;
  }

  // ============================
  //       LOGIN METHOD
  // ============================
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        body: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Assuming the API returns a token upon login
        final token = data['token'] as String?;
        if (token != null) {
          setAuthToken(token); // Store the token
        }
        
        return data['user'];
      }

      return null;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // ============================
  //       REGISTER METHOD
  // ============================
  static Future<Map<String, dynamic>?> register(
      String fullName, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        body: {
          "fullName": fullName,
          "email": email,
          "password": password,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Assuming the API returns a token upon registration
        final token = data['token'] as String?;
        if (token != null) {
          setAuthToken(token); // Store the token
        }
        
        return data['user'];
      }

      print("Registration failed: ${response.statusCode}, ${response.body}");
      return null;
    } catch (e) {
      print("Error during registration: $e");
      return null;
    }
  }
  
  // ============================
  //     FETCH CURRENT USER
  // ============================
  static Future<User> fetchCurrentUser() async {
    if (_authToken == null) {
      throw Exception("User is not authenticated. Please log in.");
    }
    
    // Using /me path as the latest attempt
    final uri = Uri.parse("$baseUrl/me"); 
    print("Attempting to fetch user profile from: $uri"); 

    try {
      final response = await http.get(
        uri, 
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_authToken",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // NEW NESTING CHECK: Try parsing from the root, then check 'user' key, then 'data' key.
        Map<String, dynamic> userData;
        if (responseData.containsKey('user')) {
          userData = responseData['user'] as Map<String, dynamic>;
        } else if (responseData.containsKey('data')) {
           userData = responseData['data'] as Map<String, dynamic>;
        } else {
          userData = responseData; // Assume root is the user object
        }

        return User.fromJson(userData);
      } else {
        print("Failed to fetch user: ${response.statusCode}, ${response.body}");
        throw Exception("Failed to fetch user profile: Server returned ${response.statusCode}. Please verify the server route /me exists and returns a valid user object.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
      rethrow; 
    }
  }


  // ============================
  //     SUBMIT INCIDENT METHOD
  // ============================
  static Future<bool> submitIncident(Incident incident) async {
    // You might want to add token to this header as well for protection
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/incidents"),
        headers: {
          "Content-Type": "application/json",
          if (_authToken != null) "Authorization": "Bearer $_authToken",
        },
        body: jsonEncode(incident.toJson()),
      );

      print("Sent Incident JSON: ${incident.toJson()}");
      print("Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Failed to submit: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error submitting incident: $e");
      return false;
    }
  }

  // ============================
  //     GET ALL INCIDENTS
  // ============================
  static Future<List<Incident>> getIncidents() async {
    // You might want to add token to this header as well for protection
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/incidents"),
        headers: {
          if (_authToken != null) "Authorization": "Bearer $_authToken",
        },
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((i) => Incident.fromJson(i)).toList();
      }

      return [];
    } catch (e) {
      print("Error fetching incidents: $e");
      return [];
    }
  }

  // ============================
  //     GET SINGLE INCIDENT
  // ============================
  static Future<Incident?> getIncident(int id) async {
    // You might want to add token to this header as well for protection
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/incidents/$id"),
        headers: {
          if (_authToken != null) "Authorization": "Bearer $_authToken",
        },
      );

      if (response.statusCode == 200) {
        return Incident.fromJson(jsonDecode(response.body));
      }

      return null;
    } catch (e) {
      print("Error getting incident: $e");
      return null;
    }
  }

  // ============================
  //     UPDATE INCIDENT (optional)
  // ============================
  static Future<bool> updateIncident(int id, Map<String, dynamic> data) async {
    // You must add token to this header for protection
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/incidents/$id"),
        headers: {
          "Content-Type": "application/json",
          if (_authToken != null) "Authorization": "Bearer $_authToken",
        },
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Update error: $e");
      return false;
    }
  }

  // ============================
  //     DELETE INCIDENT
  // ============================
  static Future<bool> deleteIncident(int id) async {
    // You must add token to this header for protection
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/incidents/$id"),
        headers: {
          if (_authToken != null) "Authorization": "Bearer $_authToken",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Delete error: $e");
      return false;
    }
  }
}