// lib/models/user_model.dart
import 'package:frontend_weft/features/post/model/post_model.dart';

class UserModel {
  final String name;
  final String username;
  final String batch;
  final String branch;
  final String className;
  final String? image_url;
  final List<Post> posts;

  UserModel({
    required this.name,
    required this.username,
    required this.batch,
    required this.branch,
    required this.className,
    this.image_url,
    this.posts = const [],
  });

  UserModel copyWith({
    String? name,
    String? username,
    String? batch,
    String? branch,
    String? className,
    String? image_url,
    List<Post>? posts,
  }) {
    return UserModel(
      name: name ?? this.name,
      username: username ?? this.username,
      batch: batch ?? this.batch,
      branch: branch ?? this.branch,
      className: className ?? this.className,
      image_url: image_url ?? this.image_url,
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
      'image_url': image_url,
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
      image_url: json['image_url'],
      posts: (json['posts'] as List<dynamic>? ?? [])
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}