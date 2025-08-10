import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/core/http_client.dart';

final skillsApiServiceProvider = Provider<SkillsApiService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return SkillsApiService(httpClient);
});

class SkillsApiService {
  static const String baseUrl = ServerConstants.baseUrl;
  final AppHttpClient _httpClient;

  SkillsApiService(this._httpClient);

  /// Add a new skill - automatically includes AccessToken as Cookie
  /// Uses URL query parameter as expected by existing backend
  Future<Map<String, dynamic>?> addSkill(String skillName) async {
    try {
      final url = Uri.parse('$baseUrl/skills/add?skill=${Uri.encodeComponent(skillName)}');
      final response = await _httpClient.post(url);

      print("🔵 POST Add Skill URL: $url");
      print(" Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend doesn't return JSON, so we create a success response
        return {'success': true, 'skill_name': skillName};
      } else {
        print("❌ Failed to add skill: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error adding skill: $e");
      return null;
    }
  }

  /// Remove a skill - Since backend doesn't have remove endpoint,
  /// this is handled frontend-only until backend support is added
  Future<bool> removeSkill(String skillName, List<String> currentSkills) async {
    try {
      // Frontend-only removal - in production this would need backend support
      // For now we return true to indicate successful frontend removal
      return true;
    } catch (e) {
      print("❌ Error removing skill: $e");
      return false;
    }
  }
}
