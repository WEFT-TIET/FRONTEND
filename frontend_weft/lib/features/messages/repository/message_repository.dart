import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_weft/features/messages/models/message_model.dart';
import 'package:frontend_weft/features/messages/service/socket_service.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final socket = ref.read(socketServiceProvider);
  return MessageRepository(socket);
});

class MessageRepository {
  MessageRepository(this._socket);

  final SocketService _socket;
  static const String _messagesKey = 'cached_messages';
  static const String _conversationsKey = 'cached_conversations';

  // Cache messages locally
  Future<void> cacheMessages(List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = messages.map((m) => m.toJson()).toList();
      await prefs.setString(_messagesKey, jsonEncode(messagesJson));
    } catch (e) {
      print('Error caching messages: $e');
    }
  }

  // Load cached messages
  Future<List<ChatMessage>> getCachedMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesString = prefs.getString(_messagesKey);
      if (messagesString == null) return [];

      final messagesJson = jsonDecode(messagesString) as List;
      return messagesJson
          .map((json) => ChatMessage.fromBackend(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading cached messages: $e');
      return [];
    }
  }

  // Get messages for a specific conversation
  Future<List<ChatMessage>> getConversationMessages(int userId, int otherUserId) async {
    final cachedMessages = await getCachedMessages();
    return cachedMessages.where((msg) {
      return (msg.senderId == userId && msg.receiverId == otherUserId) ||
             (msg.senderId == otherUserId && msg.receiverId == userId);
    }).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // Send message through socket
  Future<void> sendMessage({
    required int senderId,
    required int receiverId,
    required String content,
  }) async {
    _socket.sendMessage(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
    );
  }

  // Mark message as read
  void markMessageAsRead({required int senderId, required String messageUuid}) {
    _socket.markMessageRead(senderId: senderId, messageUuid: messageUuid);
  }

  // Fetch messages from server
  Future<void> fetchMessages(int page) async {
    await _socket.fetchMessages(page);
  }

  // Connect to socket
  Future<void> connect() async {
    await _socket.connect();
  }

  // Get socket streams
  Stream<ChatMessage> get messagesStream => _socket.messagesStream;
  Stream<MessageReceivedResponse> get messageReceivedStream => _socket.messageReceivedStream;
  Stream<MessageDeliveredResponse> get messageDeliveredStream => _socket.messageDeliveredStream;
  Stream<MessageReadResponse> get messageReadStream => _socket.messageReadStream;
  Stream<bool> get authStatusStream => _socket.authStatusStream;
  Stream<String> get errorStream => _socket.errorStream;

  bool get isConnected => _socket.isConnected;

  void dispose() {
    _socket.dispose();
  }
}

// Conversation model for the messages list
class ConversationSummary {
  final int userId;
  final String userName;
  final String? userAvatar;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final bool isOnline;
  final DateTime lastActivity;

  ConversationSummary({
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.lastMessage,
    this.unreadCount = 0,
    this.isOnline = false,
    required this.lastActivity,
  });

  ConversationSummary copyWith({
    int? userId,
    String? userName,
    String? userAvatar,
    ChatMessage? lastMessage,
    int? unreadCount,
    bool? isOnline,
    DateTime? lastActivity,
  }) {
    return ConversationSummary(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'is_online': isOnline,
      'last_activity': lastActivity.toIso8601String(),
    };
  }

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      userAvatar: json['user_avatar'] as String?,
      lastMessage: json['last_message'] != null
          ? ChatMessage.fromBackend(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      isOnline: json['is_online'] as bool? ?? false,
      lastActivity: DateTime.parse(json['last_activity'] as String),
    );
  }
}