class Post {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String username;
  final String createdAt;
  final int likesCount;
  final int commentsCount;
  final bool liked;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.username,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.liked,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      username: json['username'] ?? 'Anonymous',
      createdAt: json['createdAt'] ??
          json['created_at'] ??
          DateTime.now().toIso8601String(),
      likesCount: json['likesCount'] ?? json['likes_count'] ?? 0,
      commentsCount: json['commentsCount'] ?? json['comments_count'] ?? 0,
      liked: json['liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'username': username,
      'createdAt': createdAt,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'liked': liked,
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? username,
    String? createdAt,
    int? likesCount,
    int? commentsCount,
    bool? liked,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      liked: liked ?? this.liked,
    );
  }
}
