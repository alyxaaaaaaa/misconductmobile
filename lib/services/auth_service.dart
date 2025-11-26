// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter_isuli_final/base/variables.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // class ApiService {
// //   static Future<Map<String, String>> _headers() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     final token = prefs.getString('token');

// //     print(' Bearer Token: $token');

// //     return {
// //       'Content-Type': 'application/json',
// //       'Accept': 'application/json',
// //       if (token != null) 'Authorization': 'Bearer $token',
// //     };
// //   }
// // }

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_isuli_final/base/variables.dart';

// class AuthService {
//   static Future<bool> login(String email, String password) async {
//     final url = Uri.parse('$baseURL/login');

//     final response = await http.post(
//       url,
//       headers: {'Accept': 'application/json'},
//       body: {'email': email, 'password': password},
//     );

//     print('Login Status: ${response.statusCode}');
//     print('Response: ${response.body}');

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);

//       // retrieve token from Laravel API
//       final token = data['token'];

//       if (token == null) return false;

//       // save token
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString('token', token);

//       print('🔑 Token saved!');
//       return true;
//     }

//     return false;
//   }

//   /// Remove token from storage → logout
//   static Future<void> logout() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('token');
//     print('🔑 Token removed!');
//   }

//   /// Check if user is logged in (token exists)
//   static Future<bool> isLoggedIn() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.containsKey('token');
//   }

//   /// Get token for authenticated API calls
//   static Future<String?> getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:misconductmobile/variables.dart';

class AuthService {
  // Login
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {'email': email, 'password': password},
    );

    print('Login Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      if (token == null) return false;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      print('🔑 Token saved!');
      return true;
    }

    return false;
  }

  // Logout
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    print('🔑 Token removed!');
  }

  // Check login status
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  // Get token
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final body = {
      'fullname': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: body,
      );
      final data = jsonDecode(response.body);
      return {'statusCode': response.statusCode, 'data': data};
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'message': 'Error: $e'},
      };
    }
  }
}
