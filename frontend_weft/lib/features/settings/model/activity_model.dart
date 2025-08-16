class ActivityRecord {
  final String? type;
  final int? postId;
  final String? postTitle;
  final int? commentId;
  final String? commentContent;
  final DateTime createdAt;

  ActivityRecord({
    required this.type,
    required this.postId,
    required this.postTitle,
    required this.commentId,
    required this.commentContent,
    required this.createdAt,
  });

  // Helper methods to check activity type
  bool get isLike => type?.toLowerCase() == 'like';
  bool get isComment => type?.toLowerCase() == 'comment';

  factory ActivityRecord.fromJson(Map<String, dynamic> json) {
    return ActivityRecord(
      type: json['Type'] as String? ?? json['type'] as String?,
      postId: json['PostID'] as int? ?? json['postId'] as int?,
      postTitle: json['PostTitle'] as String? ?? json['postTitle'] as String?,
      commentId: json['CommentID'] as int? ?? json['commentId'] as int?,
      commentContent: json['CommentContent'] as String? ?? json['commentContent'] as String?,
      createdAt: _parseDateTime(json['CreatedAt'] ?? json['createdAt'] ?? ''),
    );
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null || dateValue == '') {
      return DateTime.now();
    }
    
    if (dateValue is String) {
      // Handle Go's zero time value
      if (dateValue == '0001-01-01T00:00:00Z') {
        return DateTime.now();
      }
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'Type': type,
      'PostID': postId,
      'PostTitle': postTitle,
      'CommentID': commentId,
      'CommentContent': commentContent,
      'CreatedAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ActivityRecord(type: $type, postId: $postId, postTitle: $postTitle, commentId: $commentId, commentContent: $commentContent, createdAt: $createdAt)';
  }
}
