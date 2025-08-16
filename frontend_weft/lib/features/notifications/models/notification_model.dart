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
    // Use the message from backend if available, otherwise fall back to default messages
    if (message.isNotEmpty && message != 'interacted with your content') {
      return message;
    }
    
    switch (type) {
      case NotificationType.like:
        return 'liked your post';
      case NotificationType.comment:
        return 'commented: "$commentText"';
      case NotificationType.follow:
        return 'started following you';
      case NotificationType.mention:
        return 'mentioned you';
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
    // Get the notification type from backend response
    final notificationType = json['type'] ?? json['Type'] ?? 'system';
    final taggerUsername = json['tagger_username'] ?? json['TaggerUsername'] ?? 'Unknown User';
    
    // Generate message based on notification type and tagger username
    String getMessage(String type, String username) {
      switch (type.toLowerCase()) {
        case 'post':
          return 'You were tagged in a post by $username';
        case 'comment':
          return 'You were tagged in a comment by $username';
        case 'like':
          return '$username liked your post';
        case 'follow':
          return '$username started following you';
        case 'mention':
          return '$username mentioned you';
        default:
          return '$username interacted with your content';
      }
    }

    final message = getMessage(notificationType, taggerUsername);

    // Create a simple user model from the tagger information
    UserModel? userData;
    try {
      if (json['tagger_username'] != null || json['TaggerUsername'] != null) {
        userData = UserModel(
          name: taggerUsername,
          username: taggerUsername,
          year: '',
          branch: '',
          imageUrl: null, // Backend doesn't provide tagger image in this response
        );
      }
    } catch (e) {
      print('Error creating user data: $e');
      userData = null;
    }

    // Map notification type to enum
    NotificationType getNotificationType(String type) {
      switch (type.toLowerCase()) {
        case 'post':
          return NotificationType.mention; // Tagged in post
        case 'comment':
          return NotificationType.mention; // Tagged in comment
        case 'like':
          return NotificationType.like;
        case 'follow':
          return NotificationType.follow;
        default:
          return NotificationType.system;
      }
    }

    return NotificationModel(
      id: json['id']?.toString() ?? 
           json['comment_id']?.toString() ?? 
           json['CommentID']?.toString() ?? 
           json['post_id']?.toString() ?? 
           json['PostID']?.toString() ?? 
           DateTime.now().millisecondsSinceEpoch.toString(),
      userId: json['user_id']?.toString() ?? json['UserID']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? json['PostID']?.toString(),
      type: getNotificationType(notificationType),
      message: message,
      actionText: json['action_text'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
      user: userData,
      postImage: json['post_image'],
      commentText: json['comment_text'],
      likeCount: json['like_count'],
      commentCount: json['comment_count'],
    );
  }
} 