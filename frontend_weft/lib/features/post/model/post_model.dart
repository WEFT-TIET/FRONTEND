class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String content;
  final String createdAt;
  final int likesCount;
  final int commentsCount;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      title: json['title'],
      content: json['content'],
      createdAt: json['created_at'],
      likesCount: json['likes_count'],
      commentsCount: json['comments_count'],
    );
  }
}
