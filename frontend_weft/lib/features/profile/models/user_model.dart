// lib/models/user_model.dart
import 'package:frontend_weft/features/post/model/post_model.dart';
import 'package:frontend_weft/features/profile/models/skill_model.dart';

class UserModel {
  final String name;
  final String username;
  final String year;
  final String branch;
  final String? imageUrl;
  final String? email;
  final String? instagramId;
  final List<Post> posts;
  final List<SkillModel> skills;

  UserModel({
    required this.name,
    required this.username,
    required this.year,
    required this.branch,
    this.imageUrl,
    this.email,
    this.instagramId,
    this.posts = const [],
    this.skills = const [],
  });

  /// Check if the user is verified (has Thapar email)
  bool get isVerified {
    if (email == null) return false;
    return email!.toLowerCase().endsWith('@thapar.edu') || 
           email!.toLowerCase().contains('thapar.edu');
  }

  UserModel copyWith({
    String? name,
    String? username,
    String? year,
    String? branch,
    String? imageUrl,
    String? email,
    String? instagramId,
    List<Post>? posts,
    List<SkillModel>? skills,
  }) {
    return UserModel(
      name: name ?? this.name,
      username: username ?? this.username,
      year: year ?? this.year,
      branch: branch ?? this.branch,
      imageUrl: imageUrl ?? this.imageUrl,
      email: email ?? this.email,
      instagramId: instagramId ?? this.instagramId,
      posts: posts ?? this.posts,
      skills: skills ?? this.skills,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'year': year,
      'branch': branch,
      'image_url': imageUrl,
      'email': email,
      'instagramId': instagramId,
      'posts': posts.map((post) => post.toJson()).toList(),
      'skills': skills,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      year: json['year'] ?? '',
      branch: json['branch'] ?? '',
      imageUrl: json['image_url'],
      email: json['email'],
      instagramId: json['instagramId'],
      posts: (json['posts'] as List<dynamic>? ?? [])
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
      skills: (json['skills'] as List<dynamic>? ?? [])
          .map((skillJson) => SkillModel.fromJson(skillJson as Map<String, dynamic>))
          .toList(),
          );
  }
}