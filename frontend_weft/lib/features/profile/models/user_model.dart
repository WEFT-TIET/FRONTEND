// lib/models/user_model.dart
import 'package:frontend_weft/features/post/model/post_model.dart';

class UserModel {
  final String name;
  final String username;
  final String batch;
  final String branch;
  final String className;
  final String? profileImagePath;
  final List<Post> posts;

  UserModel({
    required this.name,
    required this.username,
    required this.batch,
    required this.branch,
    required this.className,
    this.profileImagePath,
    this.posts = const [],
  });

  UserModel copyWith({
    String? name,
    String? username,
    String? batch,
    String? branch,
    String? className,
    String? profileImagePath,
    List<Post>? posts,
  }) {
    return UserModel(
      name: name ?? this.name,
      username: username ?? this.username,
      batch: batch ?? this.batch,
      branch: branch ?? this.branch,
      className: className ?? this.className,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      posts: posts ?? this.posts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'batch': batch,
      'branch': branch,
      'className': className,
      'profileImagePath': profileImagePath,
      'posts': posts.map((post) => post.toJson()).toList(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      batch: json['batch'] ?? '',
      branch: json['branch'] ?? '',
      className: json['className'] ?? json['class_id'] ?? '',
      profileImagePath: json['profileImagePath'],
      posts: (json['posts'] as List<dynamic>? ?? [])
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}