import 'package:uuid/uuid.dart';

class ChatMessage {
  final int? id; // Assigned by backend when persisted
  final String uuid; // Client-generated UUID for local tracking
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime createdAt;
  final bool delivered;
  final bool read;

  ChatMessage({
    this.id,
    required this.uuid,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.delivered = false,
    this.read = false,
  });

  factory ChatMessage.outgoing({
    required int senderId,
    required int receiverId,
    required String content,
  }) {
    return ChatMessage(
      uuid: const Uuid().v4(),
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      createdAt: DateTime.now(),
    );
  }

  ChatMessage copyWith({
    int? id,
    String? uuid,
    int? senderId,
    int? receiverId,
    String? content,
    DateTime? createdAt,
    bool? delivered,
    bool? read,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      delivered: delivered ?? this.delivered,
      read: read ?? this.read,
    );
  }
}
