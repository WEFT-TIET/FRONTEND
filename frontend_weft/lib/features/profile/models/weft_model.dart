// lib/models/weft_model.dart
class WeftModel {
  final String id;
  final String date;
  final String time;
  final String content;
  final int likes;
  final int comments;
  final DateTime createdAt;

  WeftModel({
    required this.id,
    required this.date,
    required this.time,
    required this.content,
    required this.likes,
    required this.comments,
    required this.createdAt,
  });

  WeftModel copyWith({
    String? id,
    String? date,
    String? time,
    String? content,
    int? likes,
    int? comments,
    DateTime? createdAt,
  }) {
    return WeftModel(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'content': content,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WeftModel.fromJson(Map<String, dynamic> json) {
    return WeftModel(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      content: json['content'] ?? '',
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}