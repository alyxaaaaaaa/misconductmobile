// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:misconductmobile/variables.dart'; // Contains baseUrl
import 'package:misconductmobile/models/incident.dart';
import 'package:misconductmobile/models/user.dart';

class ApiService {
  static String? _authToken;

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  static String? getAuthToken() => _authToken;

  //          LOGIN METHOD
  static Future<Map<String, dynamic>?> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        body: {"email": email, "password": password},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String?;
        if (token != null) {
          setAuthToken(token);
        }
        return data['user'];
      }
      return null;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  //          REGISTER METHOD
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
        final token = data['token'] as String?;
        if (token != null) {
          setAuthToken(token);
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

  //      FETCH CURRENT USER
  static Future<User> fetchCurrentUser() async {
    if (_authToken == null) {
      throw Exception("User is not authenticated. Please log in.");
    }
    final uri = Uri.parse("$baseUrl/me");
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
        Map<String, dynamic> userData;
        if (responseData.containsKey('user')) {
          userData = responseData['user'] as Map<String, dynamic>;
        } else if (responseData.containsKey('data')) {
          userData = responseData['data'] as Map<String, dynamic>;
        } else {
          userData = responseData;
        }
        return User.fromJson(userData);
      } else {
        print("Failed to fetch user: ${response.statusCode}, ${response.body}");
        throw Exception(
            "Failed to fetch user profile: Server returned ${response.statusCode}.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
      rethrow;
    }
  }

  // ✅ UPDATED: UPDATE USER PROFILE (Returns User object for state update)
  static Future<User?> updateUserProfile(
      String name, String email, XFile? profileImageXFile) async {
    if (_authToken == null) {
      print("Error: Authentication required for profile update.");
      return null;
    }

    try {
      final Uri uri = Uri.parse("$baseUrl/user/profile"); 
      var request = http.MultipartRequest('POST', uri); 

      request.headers['Authorization'] = 'Bearer $_authToken';
      
      // Sending 'name' to match Laravel validation requirements
      request.fields['name'] = name; 
      request.fields['email'] = email;

      if (profileImageXFile != null) {
        final bytes = await profileImageXFile.readAsBytes();
        final mimeType = profileImageXFile.mimeType ?? 'image/jpeg';

        request.files.add(
          http.MultipartFile.fromBytes(
            'profile_picture', 
            bytes,
            filename: profileImageXFile.name,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Profile Update Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // 🎯 Return the fully updated User object from the API response
        return User.fromJson(responseData['user']);
      } 
      else if (response.statusCode == 422) {
          throw Exception(response.body);
      }
      else {
        print('Failed to update profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow; 
    }
  }

  // NEW: CHANGE PASSWORD
  static Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    if (_authToken == null) {
      print("Error: Authentication required for password change.");
      return false;
    }

    try {
      final http.Response response = await http.post(
        Uri.parse("$baseUrl/user/change-password"), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword, 
        }),
      );
      print("Password Change Response: ${response.statusCode} - ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  // 🚨 MODIFIED: SUBMIT INCIDENT METHOD
  static Future<dynamic> submitIncident(Incident incident) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/incidents"),
        headers: {
          "Content-Type": "application/json",
          if (_authToken != null) "Authorization": "Bearer $_authToken",
        },
        body: jsonEncode(incident.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 422) {
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print("Error submitting incident: $e");
      return false;
    }
  }

  // NEW: FETCH USER INCIDENTS
  static Future<List<Incident>> fetchUserIncidents() async {
    if (_authToken == null) {
      throw Exception("Authentication required to view incidents.");
    }
    final uri = Uri.parse("$baseUrl/incidents");
    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $_authToken",
        },
      );
      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);
        List data;
        if (responseBody is Map && responseBody.containsKey('data')) {
          data = responseBody['data'] as List;
        } else if (responseBody is List) {
          data = responseBody;
        } else {
          data = [];
        }
        return data
            .map((i) => Incident.fromJson(i as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            "Failed to load incidents: Server returned ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  // NEW: GET SINGLE INCIDENT
  static Future<Incident?> getIncident(int id) async {
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
      return null;
    }
  }

  // NEW: UPDATE INCIDENT
  static Future<bool> updateIncident(int id, Map<String, dynamic> data) async {
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
      return false;
    }
  }

  // NEW: DELETE INCIDENT
  static Future<bool> deleteIncident(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/incidents/$id"),
        headers: {
          if (_authToken != null) "Authorization": "Bearer $_authToken",
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}