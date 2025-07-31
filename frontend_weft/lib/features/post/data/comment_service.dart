import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/core/http_client.dart';
import 'package:frontend_weft/features/post/model/comment_model.dart';

final commentServiceProvider = Provider<CommentService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return CommentService(httpClient);
});

class CommentService {
  static const String baseUrl = ServerConstants.baseUrl;
  final AppHttpClient _httpClient;

  CommentService(this._httpClient);

  // Get comments for a specific post
  Future<List<Comment>> getComments(String postId) async {
    try {
      final url = Uri.parse('$baseUrl/post/comments?id=$postId');
      final response = await _httpClient.get(url);

      print("🔵 GET Comments URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is List) {
          return data.map((json) => Comment.fromJson(json)).toList();
        } else {
          print("⚠️ Unexpected response format: $data");
          return [];
        }
      } else {
        print("❌ Failed to fetch comments: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching comments: $e");
      return [];
    }
  }

  // Create a new comment
  Future<Comment?> createComment({
    required String postId,
    required String content,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/post/comment?id=$postId');
      final body = jsonEncode({'content': content});

      final response = await _httpClient.post(url, body: body);

      print("🔵 POST Create Comment URL: $url");
      print("📦 Request Body: $body");
      print("📬 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Comment.fromJson(data);
      } else {
        print("❌ Failed to create comment: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error creating comment: $e");
      return null;
    }
  }
} 