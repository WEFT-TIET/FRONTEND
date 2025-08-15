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

  
  Future<Map<String, dynamic>?> addSkill(String skillName) async {
    try {
      final url = Uri.parse('$baseUrl/skills/add?skill=${Uri.encodeComponent(skillName)}');
      final response = await _httpClient.post(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
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

  
  
  Future<bool> removeSkill(int skillId) async {
    try {
      
      
      final url = Uri.parse('$baseUrl/skills/delete?id=$skillId');
      
      
      final response = await _httpClient.delete(url);

      print("🔵 DELETE Remove Skill URL: $url");
      print(" Response (${response.statusCode}): ${response.body}");

      
      if (response.statusCode == 200) {
        return true;
      } else {
        print("❌ Failed to remove skill: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error removing skill: $e");
      return false;
    }
  }
}