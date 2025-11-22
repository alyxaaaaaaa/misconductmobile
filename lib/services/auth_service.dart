import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:misconductmobile/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  static Future<bool> login(String email, String password) async{

    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {

      String token = jsonDecode(response.body)["token"];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return true;
    } else {
      return false;
    }

  }
}