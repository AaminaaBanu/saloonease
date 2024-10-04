import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  // Login API call
  static Future<String?> login(String email, String password) async {
    final String apiUrl = '$_baseUrl/login';
    final data = {
      'email': email,
      'password': password,
      'device_name': 'FlutterApp',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var loginResponse = jsonDecode(response.body);
        final token = loginResponse['token'];

        // Save the token to SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        return token;
      } else {
        print('Failed to log in: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }
}
