import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/core/http_client.dart';
import 'package:frontend_weft/features/settings/models/user_model.dart';


final settingsApiServiceProvider = Provider<SettingsApiService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return SettingsApiService(httpClient);
});

class SettingsApiService {
  static const String baseUrl = ServerConstants.baseUrl;
  final AppHttpClient _httpClient;

  SettingsApiService(this._httpClient);

  /// Get user settings - automatically includes AccessToken as Cookie
  Future<UserModel?> getUserSettings() async {
    try {
      final url = Uri.parse('$baseUrl/settings');
      final response = await _httpClient.get(url);

      print("🔵 GET Settings URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else {
        print("❌ Failed to fetch settings: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching settings: $e");
      return null;
    }
  }

  /// Update user settings - automatically includes AccessToken as Cookie
  Future<bool> updateUserSettings(Map<String, dynamic> settingsData) async {
    try {
      final url = Uri.parse('$baseUrl/settings/update');
      final body = jsonEncode(settingsData);

      final response = await _httpClient.post(url, body: body);

      print("🔵 PUT Settings Update URL: $url");
      print("📦 Request Body: $body");
      print("📬 Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Error updating settings: $e");
      return false;
    }
  }
}