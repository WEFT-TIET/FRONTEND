// lib/features/notifications/models/notification_model.dart
import 'package:flutter/material.dart';
import 'package:frontend_weft/features/profile/models/user_model.dart';

enum NotificationType {
  like,
  comment,
  follow,
  mention,
  post,
  system,
}

class NotificationModel {
  final String id;
  final String userId;
  final String? postId;
  final NotificationType type;
  final String message;
  final String? actionText;
  final DateTime createdAt;
  final bool isRead;
  final UserModel? user;
  final String? postImage;
  final String? commentText;
  final int? likeCount;
  final int? commentCount;

  const NotificationModel({
    required this.id,
    required this.userId,
    this.postId,
    required this.type,
    required this.message,
    this.actionText,
    required this.createdAt,
    this.isRead = false,
    this.user,
    this.postImage,
    this.commentText,
    this.likeCount,
    this.commentCount,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  String get displayMessage {
    switch (type) {
      case NotificationType.like:
        return 'liked your post';
      case NotificationType.comment:
        return 'commented: "$commentText"';
      case NotificationType.follow:
        return 'started following you';
      case NotificationType.mention:
        return 'mentioned you in a comment';
      case NotificationType.post:
        return 'posted something new';
      case NotificationType.system:
        return message;
    }
  }

  IconData get actionIcon {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.follow:
        return Icons.person_add;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.post:
        return Icons.post_add;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color get actionColor {
    switch (type) {
      case NotificationType.like:
        return Colors.red;
      case NotificationType.comment:
        return Colors.blue;
      case NotificationType.follow:
        return Colors.green;
      case NotificationType.mention:
        return Colors.orange;
      case NotificationType.post:
        return Colors.purple;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? postId,
    NotificationType? type,
    String? message,
    String? actionText,
    DateTime? createdAt,
    bool? isRead,
    UserModel? user,
    String? postImage,
    String? commentText,
    int? likeCount,
    int? commentCount,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      type: type ?? this.type,
      message: message ?? this.message,
      actionText: actionText ?? this.actionText,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      user: user ?? this.user,
      postImage: postImage ?? this.postImage,
      commentText: commentText ?? this.commentText,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'type': type.name,
      'message': message,
      'action_text': actionText,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'user': user?.toJson(),
      'post_image': postImage,
      'comment_text': commentText,
      'like_count': likeCount,
      'comment_count': commentCount,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      postId: json['post_id'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      message: json['message'] ?? '',
      actionText: json['action_text'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      isRead: json['is_read'] ?? false,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      postImage: json['post_image'],
      commentText: json['comment_text'],
      likeCount: json['like_count'],
      commentCount: json['comment_count'],
    );
  }
}

// Mock data for development
class MockNotificationData {
  static List<NotificationModel> getNotifications() {
    return [
      NotificationModel(
        id: '1',
        userId: 'user1',
        postId: 'post1',
        type: NotificationType.like,
        message: 'liked your post',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        user: UserModel(
          name: 'Rahul Kumar',
          username: 'rahul_kumar',
          year: '2024',
          branch: 'COE',
          image_url: 'lib/core/assets/profile_photo.jpeg',
        ),
        postImage: 'lib/core/assets/neeraj_pepsu.png',
        likeCount: 12,
      ),
      NotificationModel(
        id: '2',
        userId: 'user2',
        postId: 'post2',
        type: NotificationType.comment,
        message: 'commented on your post',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        user: UserModel(
          name: 'Priya Sharma',
          username: 'priya_sharma',
          year: '2023',
          branch: 'ECE',
          image_url: 'lib/core/assets/profile_photo.jpeg',
        ),
        commentText: 'Great post! Keep it up! 🚀',
        postImage: 'lib/core/assets/neeraj_pepsu.png',
      ),
      NotificationModel(
        id: '3',
        userId: 'user3',
        type: NotificationType.follow,
        message: 'started following you',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        user: UserModel(
          name: 'Amit Patel',
          username: 'amit_patel',
          year: '2025',
          branch: 'COPC',
          image_url: 'lib/core/assets/profile_photo.jpeg',
        ),
      ),
      NotificationModel(
        id: '4',
        userId: 'user4',
        postId: 'post3',
        type: NotificationType.mention,
        message: 'mentioned you in a comment',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        user: UserModel(
          name: 'Neha Singh',
          username: 'neha_singh',
          year: '2024',
          branch: 'ENC',
          image_url: 'lib/core/assets/profile_photo.jpeg',
        ),
        commentText: 'Hey @rudra_yadav, check this out!',
      ),
      NotificationModel(
        id: '5',
        userId: 'user5',
        postId: 'post4',
        type: NotificationType.post,
        message: 'posted something new',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        user: UserModel(
          name: 'Vikram Malhotra',
          username: 'vikram_malhotra',
          year: '2023',
          branch: 'IDFK',
          image_url: 'lib/core/assets/profile_photo.jpeg',
        ),
        postImage: 'lib/core/assets/neeraj_pepsu.png',
      ),
    ];
  }
} 