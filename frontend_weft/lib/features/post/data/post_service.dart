import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_weft/features/post/model/post_model.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_local_repository.dart';

final postServiceProvider = Provider<PostService>((ref) {
  return PostService(ref);
});

class PostService {
  final Ref ref;
  static const String baseUrl = ServerConstants.baseUrl;

  PostService(this.ref);

  Future<String> _getAccessToken() async {
    final token = await ref.read(authLocalRepositoryProvider).getAccessToken();
    if (token == null) {
      throw Exception("Access token not found. Please login again.");
    }
    return token;
  }

  /// Create a new post
  Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
  }) async {
    final token = await _getAccessToken();

    final response = await http.post(
      Uri.parse('$baseUrl/post/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'title': title, 'content': content}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create post: ${response.body}");
    }
  }

  /// Get posts (with optional ID filter)
  Future<List<PostModel>> getPosts({String? id}) async {
    final token = await _getAccessToken();

    String url = '$baseUrl/post/view';
    if (id != null) {
      url += '?id=$id';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load posts: ${response.body}");
    }
  }

  /// Like a post
  Future<Map<String, dynamic>> likePost(String postId) async {
    final token = await _getAccessToken();

    final response = await http.post(
      Uri.parse('$baseUrl/post/like?id=$postId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to like post: ${response.body}");
    }
  }

  /// Get comments for a post
  Future<List<CommentModel>> getComments(String postId) async {
    final token = await _getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/post/comments?id=$postId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => CommentModel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load comments: ${response.body}");
    }
  }

  /// Add a comment to a post
  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String content,
  }) async {
    final token = await _getAccessToken();

    final response = await http.post(
      Uri.parse('$baseUrl/post/comment?id=$postId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to add comment: ${response.body}");
    }
  }
}

// Comment Model
class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String content;
  final String createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      content: json['content'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'user_name': userName,
      'content': content,
      'created_at': createdAt,
    };
  }
}
