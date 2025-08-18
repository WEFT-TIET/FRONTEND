import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/core/http_client.dart';
import 'package:frontend_weft/features/auth/model/user_model.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'registration_storage.dart';

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

  /// Send registration request and trigger OTP email
  Future<String> initiateRegistration(Map<String, dynamic> userData) async {
    print("🚀 Registration initiation request: $userData");
    
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/register'),
      body: jsonEncode(userData),
    );

    print("📡 Registration response status: ${response.statusCode}");
    print("📡 Registration response body: ${response.body}");

    if (response.statusCode == 200) {
      // Backend returns "Verification mail sent"
      return response.body;
    } else {
      print("❌ Registration failed: ${response.statusCode} ${response.body}");
      throw Exception("Registration failed: ${response.body}");
    }
  }

  /// Complete registration with OTP verification
  Future<User> completeRegistration(String email, String otp) async {
    print("🔐 Completing registration for: $email with OTP: $otp");
    
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/complete/registration'),
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    print("📡 Complete registration response status: ${response.statusCode}");
    print("📡 Complete registration response body: ${response.body}");

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final accessToken = data['AccessToken'] ?? '';
      final refreshToken = data['RefreshToken'] ?? '';
      
      print("🔑 Access Token received: ${accessToken.isNotEmpty ? 'Yes' : 'No'}");
      print("🔑 Refresh Token received: ${refreshToken.isNotEmpty ? 'Yes' : 'No'}");
      
      // Extract user info from JWT token
      String userId = '';
      String userEmail = '';
      if (accessToken.isNotEmpty) {
        try {
          final payload = Jwt.parseJwt(accessToken);
          userId = payload['sub']?.toString() ?? '';
          userEmail = payload['email'] ?? '';
          print("👤 User ID from token: $userId");
          print("📧 Email from token: $userEmail");
        } catch (e) {
          print("⚠️ Could not parse JWT token: $e");
        }
      }
      
      final user = User(
        id: userId,
        name: '', // Will be populated from profile if needed
        email: userEmail,
        year: '',
        branch: '',
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      
      print("✅ Registration completed successfully");
      return user;
    } else {
      print("❌ Registration completion failed: ${response.statusCode} ${response.body}");
      throw Exception("OTP verification failed: ${response.body}");
    }
  }

  /// Resend OTP (triggers the registration endpoint again)
  Future<String> resendOtp(String email) async {
    print("🔄 Resending OTP for: $email");
    
    // Get stored registration data
    final registrationData = await RegistrationStorage.getRegistrationData();
    if (registrationData == null) {
      throw Exception("No registration data found. Please start registration again.");
    }
    
    // Verify the email matches
    if (registrationData['email'] != email) {
      throw Exception("Email mismatch. Please start registration again.");
    }
    
    // Trigger registration again to resend OTP
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/register'),
      body: jsonEncode(registrationData),
    );

    print("📡 Resend OTP response status: ${response.statusCode}");
    print("📡 Resend OTP response body: ${response.body}");

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception("Failed to resend OTP: ${response.body}");
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
