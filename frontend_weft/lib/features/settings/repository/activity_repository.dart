import 'dart:convert';
import 'package:frontend_weft/core/http_client.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/features/settings/model/activity_model.dart';
import 'package:frontend_weft/features/post/model/post_model.dart';

class ActivityRepository {
  final AppHttpClient _httpClient;
  static const String baseUrl = ServerConstants.baseUrl;

  ActivityRepository(this._httpClient);

  Future<List<ActivityRecord>> fetchUserActivity() async {
    try {
      final url = Uri.parse('$baseUrl/activity');
      final response = await _httpClient.get(url);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Extract the activities array from response
        final List<dynamic> activitiesJson = responseData['activities'] ?? [];
        
        return activitiesJson
            .map((json) => ActivityRecord.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch user activity: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user activity: $e');
    }
  }

  Future<Post?> fetchPostById(int postId) async {
    try {
      final url = Uri.parse('$baseUrl/post/view?id=$postId');
      final response = await _httpClient.get(url);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return Post.fromJson(responseData);
      } else {
        // Return null if post not found or error
        return null;
      }
    } catch (e) {
      // Return null on error
      return null;
    }
  }
}
