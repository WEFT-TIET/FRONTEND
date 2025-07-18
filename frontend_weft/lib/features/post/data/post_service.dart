import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_local_repository.dart';
import 'package:frontend_weft/features/post/model/post_model.dart';
import 'package:http/http.dart' as http;

final postServiceProvider = Provider<PostService>((ref) {
  final authLocalRepository = ref.watch(authLocalRepositoryProvider);
  return PostService(authLocalRepository);
});

class PostService {
  static const String baseUrl = ServerConstants.baseUrl;
  final AuthLocalRepository _authLocalRepository;

  PostService(this._authLocalRepository);

  Future<String?> _getAccessToken() async {
    return await _authLocalRepository.getAccessToken();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAccessToken();
    print("🔑 Retrieved token: $token");

    final headers = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
      if (token != null) 'Cookie': token,
    };

    print("📤 Headers being sent: $headers");
    return headers;
  }

  Future<List<Post>> getAllPosts() async {
    try {
      final url = Uri.parse('$baseUrl/posts');
      final headers = await _getHeaders();

      final response = await http.get(url, headers: headers);

      print("🔵 GET Posts URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle different possible response formats
        List<dynamic> postsJson;
        if (data is List) {
          // Direct array response
          postsJson = data;
        } else if (data is Map && data['posts'] != null) {
          // Object with posts field
          postsJson = data['posts'];
        } else if (data is Map && data['data'] != null) {
          // Object with data field
          postsJson = data['data'];
        } else {
          // Unknown format, return empty list
          postsJson = [];
          print("⚠️ Unknown response format: $data");
        }

        print("📋 Found ${postsJson.length} posts");
        return postsJson.map((json) => Post.fromJson(json)).toList();
      } else {
        print(
          "❌ Failed to fetch posts: ${response.statusCode} - ${response.body}",
        );
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
      final headers = await _getHeaders();
      final body = jsonEncode({'title': title, 'content': content});

      final response = await http.post(url, headers: headers, body: body);

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
      final headers = await _getHeaders();

      final response = await http.get(url, headers: headers);

      print("🔵 GET Post by ID URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Post.fromJson(data);
      } else {
        print(
          "❌ Failed to fetch post: ${response.statusCode} - ${response.body}",
        );
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
      final headers = await _getHeaders();

      final response = await http.post(url, headers: headers);

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
      final headers = await _getHeaders();

      final response = await http.delete(url, headers: headers);

      print("🔵 DELETE Post URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("❌ Error deleting post: $e");
      return false;
    }
  }
}
