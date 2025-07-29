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
        
        // Get blocked users to filter out their posts
        final blockedUsers = await _getBlockedUsers();
        final blockedUserIds = blockedUsers.map((user) => user['id'].toString()).toSet();
        
        // Get current user ID to filter out their own posts from main feed
        final currentUserId = await _getCurrentUserId();
        
        // Filter out posts from blocked users and current user's own posts
        final filteredPostsJson = postsJson.where((post) {
          final postUserId = post['user_id']?.toString() ?? post['userId']?.toString() ?? '';
          return !blockedUserIds.contains(postUserId) && postUserId != currentUserId;
        }).toList();
        
        print("📋 Filtered to ${filteredPostsJson.length} posts (removed ${postsJson.length - filteredPostsJson.length} from blocked users and current user's own posts)");
        
        return filteredPostsJson.map((json) => Post.fromJson(json)).toList();
      } else {
        print("❌ Failed to fetch posts: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching posts: $e");
      return [];
    }
  }

  // Helper method to get current user ID
  Future<String> _getCurrentUserId() async {
    try {
      final url = Uri.parse('$baseUrl/profile');
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id']?.toString() ?? '';
      }
      return '';
    } catch (e) {
      print("❌ Error fetching current user ID: $e");
      return '';
    }
  }

  // Helper method to get blocked users
  Future<List<Map<String, dynamic>>> _getBlockedUsers() async {
    try {
      final url = Uri.parse('$baseUrl/blocklist');
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      print("❌ Error fetching blocked users: $e");
      return [];
    }
  }

  Future<bool> createPost({
    required String title,
    required String content,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/post/create');
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

  Future<Map<String, dynamic>?> likePost(String postId) async {
    try {
      final url = Uri.parse('$baseUrl/post/like?id=$postId');
      final response = await _httpClient.post(url);

      print("🔵 POST Like URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      print("❌ Error liking post: $e");
      return null;
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

  // Block a user
  Future<bool> blockUser(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/block/user?id=$userId');
      final response = await _httpClient.post(url);

      print("🔵 POST Block User URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error blocking user: $e");
      return false;
    }
  }

  // Unblock a user
  Future<bool> unblockUser(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/unblock/user?id=$userId');
      final response = await _httpClient.post(url);

      print("🔵 POST Unblock User URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error unblocking user: $e");
      return false;
    }
  }
}
