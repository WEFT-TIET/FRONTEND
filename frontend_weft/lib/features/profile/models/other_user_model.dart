// lib/features/profile/models/other_user_model.dart
import 'package:frontend_weft/features/post/model/post_model.dart';

class OtherUserModel {
  final String id;
  final String name;
  final String username;
  final String year;
  final String branch;
  final String? image_url;
  final String? email;
  final String? instagramId;
  final List<Post> posts;
  final List<String> skills;

  OtherUserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.year,
    required this.branch,
    this.image_url,
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

  OtherUserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? year,
    String? branch,
    String? image_url,
    String? email,
    String? instagramId,
    List<Post>? posts,
    List<String>? skills,
  }) {
    return OtherUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      year: year ?? this.year,
      branch: branch ?? this.branch,
      image_url: image_url ?? this.image_url,
      email: email ?? this.email,
      instagramId: instagramId ?? this.instagramId,
      posts: posts ?? this.posts,
      skills: skills ?? this.skills,
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
      'email': email,
      'instagramId': instagramId,
      'posts': posts.map((post) => post.toJson()).toList(),
      'skills': skills,
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
      email: json['email'],
      instagramId: json['instagramId'],
      posts: (json['posts'] as List<dynamic>? ?? [])
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
      skills: (json['skills'] as List<dynamic>? ?? [])
          .map((e) => e is Map<String, dynamic> 
              ? e['skill_name']?.toString() ?? e.toString()
              : e.toString())
          .toList(),
    );
  }

  // Factory method to create from user map (for compatibility with existing code)
  factory OtherUserModel.fromUserMap(Map<String, dynamic> userMap) {
    return OtherUserModel(
      id: userMap['id']?.toString() ?? '',
      name: userMap['name'] ?? 'Unknown User',
      username: userMap['username'] ?? 'unknown',
      year: userMap['year']?.toString() ?? '2024',
      branch: userMap['branch'] ?? 'COE',
      image_url: userMap['image_url'],
      email: userMap['email'],
      instagramId: userMap['instagramId'],
      posts: [], // Empty posts for now
      skills: (userMap['skills'] as List<dynamic>? ?? [])
          .map((e) => e is Map<String, dynamic> 
              ? e['skill_name']?.toString() ?? e.toString()
              : e.toString())
          .toList(),
    );
  }
} 