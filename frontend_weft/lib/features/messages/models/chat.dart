class Chat {
  final String id;
  final String name;
  final String username;
  final String profilePic;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final DateTime? lastSeen;

  Chat({
    required this.id,
    required this.name,
    required this.username,
    required this.profilePic,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.lastSeen,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      profilePic: json['profilePic'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'profilePic': profilePic,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  Chat copyWith({
    String? id,
    String? name,
    String? username,
    String? profilePic,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
