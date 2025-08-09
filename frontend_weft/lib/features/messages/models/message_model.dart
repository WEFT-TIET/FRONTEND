import 'package:uuid/uuid.dart';

class ChatMessage {
  final int? id; // Assigned by backend when persisted
  final String messageUuid; // Client-generated UUID for local tracking
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime createdAt;
  final bool delivered;
  final bool deliveredInformed;
  final bool read;
  final MessageStatus status; // Local status tracking

  ChatMessage({
    this.id,
    required this.messageUuid,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.delivered = false,
    this.deliveredInformed = false,
    this.read = false,
    this.status = MessageStatus.sending,
  });

  factory ChatMessage.outgoing({
    required int senderId,
    required int receiverId,
    required String content,
  }) {
    return ChatMessage(
      messageUuid: const Uuid().v4(),
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
    );
  }

  factory ChatMessage.fromBackend(Map<String, dynamic> data) {
    return ChatMessage(
      id: data['id'] is int 
          ? data['id'] 
          : (data['id'] != null ? int.tryParse(data['id'].toString()) : null),
      messageUuid: data['message_uuid']?.toString() ?? '',
      senderId: data['sender_id'] is int 
          ? data['sender_id'] 
          : int.parse(data['sender_id'].toString()),
      receiverId: data['receiver_id'] is int
          ? data['receiver_id']
          : (data['receiver_id'] != null
              ? int.parse(data['receiver_id'].toString())
              : 0),
      content: data['content']?.toString() ?? '',
      createdAt: data['created_at'] != null 
          ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      delivered: data['delivered'] == true,
      read: data['read'] == true,
      status: MessageStatus.delivered,
    );
  }

  ChatMessage copyWith({
    int? id,
    String? messageUuid,
    int? senderId,
    int? receiverId,
    String? content,
    DateTime? createdAt,
    bool? delivered,
    bool? deliveredInformed,
    bool? read,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      messageUuid: messageUuid ?? this.messageUuid,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      delivered: delivered ?? this.delivered,
      deliveredInformed: deliveredInformed ?? this.deliveredInformed,
      read: read ?? this.read,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message_uuid': messageUuid,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'delivered': delivered,
      'delivered_informed': deliveredInformed,
      'read': read,
    };
  }
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

// Response models matching backend structs
class MessageReceivedResponse {
  final String messageId;
  final String messageUuid;
  final String receiverId;

  MessageReceivedResponse({
    required this.messageId,
    required this.messageUuid,
    required this.receiverId,
  });

  factory MessageReceivedResponse.fromJson(Map<String, dynamic> json) {
    return MessageReceivedResponse(
      messageId: json['message_id']?.toString() ?? '',
      messageUuid: json['message_uuid']?.toString() ?? '',
      receiverId: json['receiver_id']?.toString() ?? '',
    );
  }
}

class MessageDeliveredResponse {
  final int messageId;
  final String messageUuid;
  final int receiverId;

  MessageDeliveredResponse({
    required this.messageId,
    required this.messageUuid,
    required this.receiverId,
  });

  factory MessageDeliveredResponse.fromJson(Map<String, dynamic> json) {
    return MessageDeliveredResponse(
      messageId: json['message_id'] is int 
          ? json['message_id'] 
          : int.parse(json['message_id'].toString()),
      messageUuid: json['message_uuid']?.toString() ?? '',
      receiverId: json['receiver_id'] is int
          ? json['receiver_id']
          : int.parse(json['receiver_id'].toString()),
    );
  }
}

class MessageReadResponse {
  final int messageId;
  final String messageUuid;
  final int senderId;

  MessageReadResponse({
    required this.messageId,
    required this.messageUuid,
    required this.senderId,
  });

  factory MessageReadResponse.fromJson(Map<String, dynamic> json) {
    return MessageReadResponse(
      messageId: json['message_id'] is int 
          ? json['message_id'] 
          : int.parse(json['message_id'].toString()),
      messageUuid: json['message_uuid']?.toString() ?? '',
      senderId: json['sender_id'] is int
          ? json['sender_id']
          : int.parse(json['sender_id'].toString()),
    );
  }
}
