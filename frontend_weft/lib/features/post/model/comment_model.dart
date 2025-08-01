class Comment {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final String createdAt;

  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['username'] ?? 'Anonymous',
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': userName,
      'content': content,
      'created_at': createdAt,
    };
  }

  Comment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? content,
    String? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 