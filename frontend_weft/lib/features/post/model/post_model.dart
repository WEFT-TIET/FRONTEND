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
  final bool verified;
  final String imageUrl; // Cloudflare image URL (optional)

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
    this.verified = false,
  this.imageUrl = '',
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // Get the raw values
    final rawLikesCount = json['likesCount'] ?? json['likes_count'] ?? 0;
    final rawLiked = json['liked'] ?? false;
    
    // Validate that if likes_count is 0, then liked should be false
    // This is a temporary fix for the backend issue
    final likesCount = rawLikesCount is int ? rawLikesCount : 0;
    final liked = likesCount > 0 ? rawLiked : false;
    
    // Debug logging to understand the backend data
    if (rawLiked && likesCount == 0) {
      print("🐛 Backend inconsistency detected for post ${json['id']}: liked=$rawLiked but likes_count=$likesCount");
      print("🔧 Fixed: Setting liked to false since likes_count is 0");
    }
    
    // Parse verification status from backend
    final verified = json['verified'] ?? false;
    if (verified) {
      print("✅ Verified user post: ${json['username']}");
    }
    
    return Post(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      username: json['username'] ?? json['user_name'] ?? 'Anonymous',
      createdAt: json['createdAt'] ??
          json['created_at'] ??
          DateTime.now().toIso8601String(),
      likesCount: likesCount,
      commentsCount: json['commentsCount'] ?? json['comments_count'] ?? 0,
      liked: liked,
      verified: verified,
  imageUrl: json['image_url'] ?? json['imageURL'] ?? '',
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
      'verified': verified,
  'image_url': imageUrl,
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
    bool? verified,
    String? imageUrl,
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
      verified: verified ?? this.verified,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
