import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:misconductmobile/variables.dart';
import 'package:misconductmobile/models/incident.dart';
import 'package:misconductmobile/models/user.dart';

class ApiService {
  static String? _authToken;
  static const String _tokenKey = 'auth_token';

  /// Initialize token from storage
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
    print('Service initialized. Loaded token: ${_authToken != null ? "Yes" : "No"}');
  }

  /// Save token persistently
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _authToken = token;
    print('🔑 Token saved to storage!');
  }

  /// Remove token
  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _authToken = null;
    print('🔑 Token removed from storage!');
  }

  static String? getAuthToken() => _authToken;

  // LOGIN
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String?;
        if (token != null) await _saveToken(token);
        return data['user'] as Map<String, dynamic>?;
      }
      print("Login failed: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // LOGOUT
  static Future<void> logout() async => _clearToken();

  // REGISTER
  static Future<Map<String, dynamic>?> register(String fullName, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"fullName": fullName, "email": email, "password": password}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String?;
        if (token != null) await _saveToken(token);
        return data['user'] as Map<String, dynamic>?;
      }
      print("Registration failed: ${response.statusCode}, ${response.body}");
      return null;
    } catch (e) {
      print("Error during registration: $e");
      return null;
    }
  }

  // FETCH CURRENT USER
  static Future<User> fetchCurrentUser() async {
    if (_authToken == null) throw Exception("User not authenticated.");
    final response = await http.get(
      Uri.parse("$baseUrl/me"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $_authToken"},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userData = data['user'] ?? data['data'] ?? data;
      return User.fromJson(userData);
    } else {
      throw Exception("Failed to fetch user: ${response.statusCode}");
    }
  }

  // UPDATE PROFILE
  static Future<User?> updateUserProfile(String name, String email, XFile? profileImage) async {
    if (_authToken == null) return null;
    try {
      final uri = Uri.parse("$baseUrl/user/profile");
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $_authToken';
      request.fields['name'] = name;
      request.fields['email'] = email;

      if (profileImage != null) {
        final bytes = await profileImage.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'profile_picture',
            bytes,
            filename: profileImage.name,
            contentType: MediaType.parse(profileImage.mimeType ?? 'image/jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else if (response.statusCode == 422) {
        throw Exception(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Error updating profile: $e");
      return null;
    }
  }

  // CHANGE PASSWORD
  static Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_authToken == null) return false;
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/user/change-password"),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_authToken'},
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error changing password: $e");
      return false;
    }
  }

  // INCIDENTS
  static Future<bool> submitIncident(Incident incident) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/incidents"),
        headers: {
          "Content-Type": "application/json",
          if (_authToken != null) "Authorization": "Bearer $_authToken",
        },
        body: jsonEncode(incident.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error submitting incident: $e");
      return false;
    }
  }

  static Future<List<Incident>> fetchUserIncidents() async {
    if (_authToken == null) throw Exception("Authentication required.");
    final response = await http.get(
      Uri.parse("$baseUrl/incidents"),
      headers: {"Authorization": "Bearer $_authToken"},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['data'] ?? data;
      return (list as List).map((e) => Incident.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch incidents: ${response.statusCode}");
    }
  }

  static Future<Incident?> getIncident(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/incidents/$id"),
        headers: {"Authorization": "Bearer $_authToken"},
      );
      if (response.statusCode == 200) return Incident.fromJson(jsonDecode(response.body));
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateIncident(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/incidents/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_authToken",
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteIncident(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/incidents/$id"),
        headers: {"Authorization": "Bearer $_authToken"},
      );
      if (response.statusCode == 403) {
        print("DELETE Forbidden: No permission.");
        return false;
      }
      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting incident: $e");
      return false;
    }
  }

  // In ApiService

  static Future<List<dynamic>> fetchIncidentStats() async {
    if (_authToken == null) throw Exception("Authentication required.");

    final response = await http.get(
      Uri.parse("$baseUrl/stats/monthly-misconduct"), // or your actual URL
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_authToken",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // data is a List, so just return it
      if (data is List) {
        return data;
      } else {
        throw Exception("Expected a list but got: ${data.runtimeType}");
      }
    } else {
      throw Exception("Failed to fetch incident stats: ${response.statusCode}");
    }
  }

  // ... (The rest of your ApiService class)

    /// NEW METHOD: Fetches misconduct counts grouped by program/course.
    /// The API returns a map where keys are program names and values are counts.
    static Future<Map<String, int>> fetchMisconductPerProgram() async {
        if (_authToken == null) throw Exception("Authentication required.");

        final response = await http.get(
            Uri.parse("$baseUrl/admin/stats/misconduct-per-program"), // Assumes this is the correct endpoint from the backend logic
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $_authToken",
            },
        );

        if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data is Map) {
                // Convert Map<String, dynamic> to Map<String, int>
                return data.map((key, value) => MapEntry(key.toString(), (value as num).toInt()));
            } else {
                throw Exception("Expected a map but got: ${data.runtimeType}");
            }
        } else {
            throw Exception("Failed to fetch program misconduct data: ${response.statusCode}");
        }
    }

// ... (The rest of your ApiService class)
}