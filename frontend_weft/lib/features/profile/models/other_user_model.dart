// lib/features/profile/models/other_user_model.dart
import 'package:frontend_weft/features/post/model/post_model.dart';

class OtherUserModel {
  final String id;
  final String name;
  final String username;
  final String year;
  final String branch;
  final String? image_url;
  final List<Post> posts;

  OtherUserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.year,
    required this.branch,
    this.image_url,
    this.posts = const [],
  });

  OtherUserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? year,
    String? branch,
    String? image_url,
    List<Post>? posts,
  }) {
    return OtherUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      year: year ?? this.year,
      branch: branch ?? this.branch,
      image_url: image_url ?? this.image_url,
      posts: posts ?? this.posts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'year': year,
      'branch': branch,
      'image_url': image_url,
      'posts': posts.map((post) => post.toJson()).toList(),
    };
  }

  factory OtherUserModel.fromJson(Map<String, dynamic> json) {
    return OtherUserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      year: json['year']?.toString() ?? '',
      branch: json['branch'] ?? '',
      image_url: json['image_url'],
      posts: (json['posts'] as List<dynamic>? ?? [])
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Factory method to create from user map (for compatibility with existing code)
  factory OtherUserModel.fromUserMap(Map<String, dynamic> userMap) {
    return OtherUserModel(
      id: userMap['id']?.toString() ?? '',
      name: userMap['name'] ?? 'Unknown User',
      username: userMap['username'] ?? 'unknown',
      year: userMap['year']?.toString() ?? '1',
      branch: userMap['branch'] ?? 'COE',
      image_url: userMap['image_url'],
      posts: [], // Empty posts for now
    );
  }
} 