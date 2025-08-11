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
    return await getPostsByPage(1);
  }

  Future<List<Post>> getPostsByPage(int page) async {
    try {
      final url = Uri.parse('$baseUrl/posts?page=$page');
      final response = await _httpClient.get(url);

      print("🔵 GET Posts URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("🔍 Raw response data: $data");

        List<dynamic> postsJson;
        if (data is List) {
          postsJson = data;
          print("🔍 Response is a List with ${postsJson.length} items");
        } else if (data is Map && data['results'] != null) {
          postsJson = data['results'];
          print("🔍 Response has 'results' field with ${postsJson.length} items");
        } else if (data is Map && data['posts'] != null) {
          postsJson = data['posts'];
          print("🔍 Response has 'posts' field with ${postsJson.length} items");
        } else if (data is Map && data['data'] != null) {
          postsJson = data['data'];
          print("🔍 Response has 'data' field with ${postsJson.length} items");
        } else {
          postsJson = [];
          print("⚠️ Unknown response format: $data");
        }

        if (postsJson.isNotEmpty) {
          print("🔍 First post structure: ${postsJson.first}");
          // Check if user information is included
          final firstPost = postsJson.first;
          if (firstPost['user'] != null) {
            print("🔍 User object in post: ${firstPost['user']}");
          }
          if (firstPost['email'] != null) {
            print("🔍 Email in post: ${firstPost['email']}");
          }
        }

        print("📋 Found ${postsJson.length} posts for page $page");
        
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

  Future<Map<String, dynamic>> deletePost(String postId) async {
    try {
      final url = Uri.parse('$baseUrl/post/delete?id=$postId');
      final response = await _httpClient.post(url);

      print("🔵 POST Delete Post URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      // Handle different response codes
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Post deleted successfully'};
      } else if (response.statusCode == 404) {
        // Check if it's endpoint not found or post not found
        final responseBody = response.body.toLowerCase();
        if (responseBody.contains('post not found')) {
          return {'success': false, 'message': 'Post not found or already deleted'};
        } else {
          print("❌ Delete post endpoint not available on server yet");
          return {'success': false, 'message': 'Delete feature temporarily unavailable'};
        }
      } else if (response.statusCode == 403) {
        return {'success': false, 'message': 'You do not have permission to delete this post'};
      } else {
        return {'success': false, 'message': 'Failed to delete post. Please try again.'};
      }
    } catch (e) {
      print("❌ Error deleting post: $e");
      return {'success': false, 'message': 'Network error. Please check your connection and try again.'};
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
