import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/core/http_client.dart';
import 'package:frontend_weft/features/post/model/post_model.dart';

final postServiceProvider = Provider<PostService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return PostService(httpClient);
});

class PostService {
  static const String baseUrl = ServerConstants.baseUrl;
  final AppHttpClient _httpClient;

  PostService(this._httpClient);

  Future<List<Post>> getAllPosts() async {
    try {
      final url = Uri.parse('$baseUrl/posts');
      final response = await _httpClient.get(url);

      print("🔵 GET Posts URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> postsJson;
        if (data is List) {
          postsJson = data;
        } else if (data is Map && data['results'] != null) {
          postsJson = data['results'];
        } else if (data is Map && data['posts'] != null) {
          postsJson = data['posts'];
        } else if (data is Map && data['data'] != null) {
          postsJson = data['data'];
        } else {
          postsJson = [];
          print("⚠️ Unknown response format: $data");
        }

        print("📋 Found ${postsJson.length} posts");
        return postsJson.map((json) => Post.fromJson(json)).toList();
      } else {
        print("❌ Failed to fetch posts: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching posts: $e");
      return [];
    }
  }

  Future<bool> createPost({
    required String title,
    required String content,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/posts');
      final body = jsonEncode({'title': title, 'content': content});

      final response = await _httpClient.post(url, body: body);

      print("🔵 POST Create URL: $url");
      print("📦 Request Body: $body");
      print("📬 Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Error creating post: $e");
      return false;
    }
  }

  Future<Post?> getPostById(String postId) async {
    try {
      final url = Uri.parse('$baseUrl/posts/$postId');
      final response = await _httpClient.get(url);

      print("🔵 GET Post by ID URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Post.fromJson(data);
      } else {
        print("❌ Failed to fetch post: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching post: $e");
      return null;
    }
  }

  Future<bool> likePost(String postId) async {
    try {
      final url = Uri.parse('$baseUrl/posts/$postId/like');
      final response = await _httpClient.post(url);

      print("🔵 POST Like URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Error liking post: $e");
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      final url = Uri.parse('$baseUrl/posts/$postId');
      final response = await _httpClient.delete(url);

      print("🔵 DELETE Post URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("❌ Error deleting post: $e");
      return false;
    }
  }
}
