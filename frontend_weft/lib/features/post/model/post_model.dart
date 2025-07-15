class Post {
  final String id;
  final String title;
  final String content;
  final String userName;
  final String createdAt;
  final int likesCount;
  final int commentsCount;

  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.userName,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      userName: json['userName'] ?? json['user_name'] ?? 'Anonymous',
      createdAt:
          json['createdAt'] ??
          json['created_at'] ??
          DateTime.now().toIso8601String(),
      likesCount: json['likesCount'] ?? json['likes_count'] ?? 0,
      commentsCount: json['commentsCount'] ?? json['comments_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'userName': userName,
      'createdAt': createdAt,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
    };
  }

  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? userName,
    String? createdAt,
    int? likesCount,
    int? commentsCount,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }
}
