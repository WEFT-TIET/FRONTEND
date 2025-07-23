import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/core/http_client.dart';
import 'package:frontend_weft/features/profile/models/user_model.dart';

final profileApiServiceProvider = Provider<ProfileApiService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return ProfileApiService(httpClient);
});

class ProfileApiService {
  static const String baseUrl = ServerConstants.baseUrl;
  final AppHttpClient _httpClient;

  ProfileApiService(this._httpClient);

  /// Get user profile - automatically includes AccessToken as Cookie
  Future<UserModel?> getUserProfile() async {
    try {
      final url = Uri.parse('$baseUrl/profile');
      final response = await _httpClient.get(url);

      print("🔵 GET Profile URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else {
        print("❌ Failed to fetch profile: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
      return null;
    }
  }

  /// Update user profile - automatically includes AccessToken as Cookie
  Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final url = Uri.parse('$baseUrl/profile/update');
      final body = jsonEncode(profileData);

      final response = await _httpClient.post(url, body: body);

      print("🔵 PUT Profile Update URL: $url");
      print("📦 Request Body: $body");
      print("📬 Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Error updating profile: $e");
      return false;
    }
  }

  /// Upload profile image - automatically includes AccessToken as Cookie
  Future<String?> uploadProfileImage(String image_url) async {
    try {
      final url = Uri.parse('$baseUrl/profile/image');
      final body = jsonEncode({'image_url': image_url});

      final response = await _httpClient.post(url, body: body);

      print("🔵 POST Profile Image Upload URL: $url");
      print("📬 Response ( [33m${response.statusCode} [0m): ${response.body}");

      if (response.statusCode == 201) {
        return image_url;
      } else {
        print("❌ Failed to upload image: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error uploading image: $e");
      return null;
    }
  }

  /// Delete user account - automatically includes AccessToken as Cookie
  Future<bool> deleteAccount() async {
    try {
      final url = Uri.parse('$baseUrl/profile/delete');
      final response = await _httpClient.delete(url);

      print("🔵 DELETE Account URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("❌ Error deleting account: $e");
      return false;
    }
  }
} 