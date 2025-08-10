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
        final payload = Jwt.parseJwt(accessToken);

        final id = payload['sub'] ?? '';
        final emailFromToken = payload['email'] ?? '';

        return User(
          id: id.toString(),
          name: '',
          email: emailFromToken,
          year: '',
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
    print("🚀 Signup request: $userData");
    
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/register'),
      body: jsonEncode(userData),
    );

    print("📡 Signup response status: ${response.statusCode}");
    print("📡 Signup response body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Just return success - tokens are automatically saved as cookies
      // Create a basic user object for state management
      final user = User(
        id: '',
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        year: userData['year'] ?? '',
        branch: userData['branch'] ?? '',
        accessToken: '',
        refreshToken: '',
      );
      
      print("✅ Signup successful");
      return user;
    } else {
      print("❌ Signup failed: ${response.statusCode} ${response.body}");
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
