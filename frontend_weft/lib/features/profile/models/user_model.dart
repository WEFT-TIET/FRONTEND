// lib/models/user_model.dart
import 'package:frontend_weft/features/post/model/post_model.dart';

class UserModel {
  final String name;
  final String username;
  final String year;
  final String branch;
  final String? image_url;
  final List<Post> posts;

  UserModel({
    required this.name,
    required this.username,
    required this.year,
    required this.branch,
    this.image_url,
    this.posts = const [],
  });

  UserModel copyWith({
    String? name,
    String? username,
    String? year,
    String? branch,
    String? image_url,
    List<Post>? posts,
  }) {
    return UserModel(
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
      'name': name,
      'username': username,
      'year': year,
      'branch': branch,
      'image_url': image_url,
      'posts': posts.map((post) => post.toJson()).toList(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      year: json['year'] ?? '',
      branch: json['branch'] ?? '',
      image_url: json['image_url'],
      posts: (json['posts'] as List<dynamic>? ?? [])
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}