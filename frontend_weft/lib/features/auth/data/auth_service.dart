import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_weft/features/auth/model/user_model.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  static const String baseUrl = ServerConstants.baseUrl;

  Future<User> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['AccessToken'];
        final refreshToken = data['RefreshToken'];
        final payload = Jwt.parseJwt(accessToken);

        final id = payload['sub'] ?? '';
        final emailFromToken = payload['email'] ?? '';

        return User(
          id: id.toString(),
          name: '',
          email: emailFromToken,
          year: '',
          classId: '',
          branch: '',
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      } else {
        throw Exception("Login failed: ${response.body}");
      }
    } catch (e) {
      print("🔥 Exception: $e");
      throw Exception("Login failed: $e");
    }
  }

  /// Sign up and return a User model
  Future<User> signup(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Signup failed: ${response.statusCode} ${response.body}");
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  /// Clear tokens on logout
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }
}
