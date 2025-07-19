import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/core/http_client.dart';
import 'package:frontend_weft/features/auth/model/user_model.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return AuthService(httpClient);
});

class AuthService {
  static const String baseUrl = ServerConstants.baseUrl;
  final AppHttpClient _httpClient;

  AuthService(this._httpClient);

  Future<User> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await _httpClient.post(
        url,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['AccessToken'];
        final refreshToken = data['RefreshToken'];
        final userData = data['user'];
        final payload = Jwt.parseJwt(accessToken);

        return User(
          id: userData['id'].toString(),
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          year: userData['year'] ?? '',
          classId: userData['class_id'] ?? '',
          branch: userData['branch'] ?? '',
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
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/register'),
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
