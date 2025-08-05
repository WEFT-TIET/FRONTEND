class Message {
  final String id;
  final String sender_id;
  final String receiver_id;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;

  Message({
    required this.id,
    required this.sender_id,
    required this.receiver_id,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      sender_id: json['sender_id'],
      receiver_id: json['receiver_id'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.sent,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': sender_id,
      'receiver_id': receiver_id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
    };
  }

  Message copyWith({
    String? id,
    String? sender_id,
    String? receiver_id,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      sender_id: sender_id ?? this.sender_id,
      receiver_id: receiver_id ?? this.receiver_id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }
}

enum MessageType {
  text,
  image,
  file,
  voice,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}
