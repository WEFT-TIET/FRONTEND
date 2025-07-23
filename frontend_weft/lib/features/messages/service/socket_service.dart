import 'dart:convert';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/message.dart';
import '../models/chat.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  String? _currentUserId;
  bool _isConnected = false;

  // Event streams
  Stream<Message>? _messageStream;
  Stream<Chat>? _chatUpdateStream;
  Stream<Map<String, dynamic>>? _typingStream;
  Stream<Map<String, dynamic>>? _onlineStatusStream;

  // Getters for streams
  Stream<Message>? get messageStream => _messageStream;
  Stream<Chat>? get chatUpdateStream => _chatUpdateStream;
  Stream<Map<String, dynamic>>? get typingStream => _typingStream;
  Stream<Map<String, dynamic>>? get onlineStatusStream => _onlineStatusStream;

  bool get isConnected => _isConnected;
  String? get currentUserId => _currentUserId;

  // Initialize socket connection
  Future<void> connect({
    required String serverUrl,
    required String userId,
    String? token,
  }) async {
    try {
      _currentUserId = userId;

      // Configure socket options
      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setExtraHeaders({
              if (token != null) 'Authorization': 'Bearer $token',
            })
            .build(),
      );

      // Set up event listeners
      _setupEventListeners();

      // Connect to server
      _socket!.connect();

      print('Socket connecting to: $serverUrl');
    } catch (e) {
      print('Socket connection error: $e');
      throw Exception('Failed to connect to socket server: $e');
    }
  }

  // Set up all socket event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      print('Socket connected successfully');
      _isConnected = true;
      
      // Join user's personal room
      if (_currentUserId != null) {
        _socket!.emit('join_user_room', {'userId': _currentUserId});
      }
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
      _isConnected = false;
    });

    _socket!.onConnectError((error) {
      print('Socket connection error: $error');
      _isConnected = false;
    });

    // Message events
    _socket!.on('new_message', (data) {
      try {
        final message = Message.fromJson(data);
        _messageStreamController.add(message);
      } catch (e) {
        print('Error parsing new message: $e');
      }
    });

    _socket!.on('message_status_update', (data) {
      try {
        final messageId = data['messageId'] as String;
        final status = MessageStatus.values.firstWhere(
          (e) => e.toString() == 'MessageStatus.${data['status']}',
          orElse: () => MessageStatus.sent,
        );
        
        _messageStatusUpdateController.add({
          'messageId': messageId,
          'status': status,
        });
      } catch (e) {
        print('Error parsing message status update: $e');
      }
    });

    // Chat events
    _socket!.on('chat_update', (data) {
      try {
        final chat = Chat.fromJson(data);
        _chatUpdateStreamController.add(chat);
      } catch (e) {
        print('Error parsing chat update: $e');
      }
    });

    // Typing events
    _socket!.on('user_typing', (data) {
      _typingStreamController.add({
        'userId': data['userId'],
        'chatId': data['chatId'],
        'isTyping': data['isTyping'],
      });
    });

    // Online status events
    _socket!.on('user_online_status', (data) {
      _onlineStatusStreamController.add({
        'userId': data['userId'],
        'isOnline': data['isOnline'],
        'lastSeen': data['lastSeen'] != null 
            ? DateTime.parse(data['lastSeen'])
            : null,
      });
    });

    // Error handling
    _socket!.on('error', (error) {
      print('Socket error: $error');
    });
  }

  // Stream controllers
  final _messageStreamController = StreamController<Message>.broadcast();
  final _messageStatusUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _chatUpdateStreamController = StreamController<Chat>.broadcast();
  final _typingStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _onlineStatusStreamController = StreamController<Map<String, dynamic>>.broadcast();

  // Initialize streams
  void _initializeStreams() {
    _messageStream = _messageStreamController.stream;
    _chatUpdateStream = _chatUpdateStreamController.stream;
    _typingStream = _typingStreamController.stream;
    _onlineStatusStream = _onlineStatusStreamController.stream;
  }

  // Send message
  void sendMessage({
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) {
    if (!_isConnected || _socket == null || _currentUserId == null) {
      throw Exception('Socket not connected or user not authenticated');
    }

    final messageData = {
      'senderId': _currentUserId,
      'receiverId': receiverId,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _socket!.emit('send_message', messageData);
  }

  // Join chat room
  void joinChatRoom(String chatId) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('join_chat', {'chatId': chatId});
  }

  // Leave chat room
  void leaveChatRoom(String chatId) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('leave_chat', {'chatId': chatId});
  }

  // Send typing indicator
  void sendTypingIndicator({
    required String chatId,
    required bool isTyping,
  }) {
    if (!_isConnected || _socket == null || _currentUserId == null) return;

    _socket!.emit('typing', {
      'userId': _currentUserId,
      'chatId': chatId,
      'isTyping': isTyping,
    });
  }

  // Mark message as read
  void markMessageAsRead(String messageId) {
    if (!_isConnected || _socket == null || _currentUserId == null) return;

    _socket!.emit('mark_as_read', {
      'messageId': messageId,
      'userId': _currentUserId,
    });
  }

  // Update online status
  void updateOnlineStatus(bool isOnline) {
    if (!_isConnected || _socket == null || _currentUserId == null) return;

    _socket!.emit('update_online_status', {
      'userId': _currentUserId,
      'isOnline': isOnline,
    });
  }

  // Block user
  void blockUser({
    required String userId,
    required String reason,
  }) {
    if (!_isConnected || _socket == null || _currentUserId == null) return;

    _socket!.emit('block_user', {
      'blockerId': _currentUserId,
      'blockedUserId': userId,
      'reason': reason,
    });
  }

  // Report user
  void reportUser({
    required String userId,
    required String reason,
    String? additionalInfo,
  }) {
    if (!_isConnected || _socket == null || _currentUserId == null) return;

    _socket!.emit('report_user', {
      'reporterId': _currentUserId,
      'reportedUserId': userId,
      'reason': reason,
      'additionalInfo': additionalInfo,
    });
  }

  // Get chat history
  void getChatHistory({
    required String chatId,
    int page = 1,
    int limit = 50,
  }) {
    if (!_isConnected || _socket == null || _currentUserId == null) return;

    _socket!.emit('get_chat_history', {
      'chatId': chatId,
      'userId': _currentUserId,
      'page': page,
      'limit': limit,
    });
  }

  // Get user's chats
  void getUserChats() {
    if (!_isConnected || _socket == null || _currentUserId == null) return;

    _socket!.emit('get_user_chats', {
      'userId': _currentUserId,
    });
  }

  // Search users
  void searchUsers(String query) {
    if (!_isConnected || _socket == null || _currentUserId == null) return;

    _socket!.emit('search_users', {
      'query': query,
      'userId': _currentUserId,
    });
  }

  // Disconnect socket
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    
    _isConnected = false;
    _currentUserId = null;
    
    // Close stream controllers
    _messageStreamController.close();
    _messageStatusUpdateController.close();
    _chatUpdateStreamController.close();
    _typingStreamController.close();
    _onlineStatusStreamController.close();
  }

  // Reconnect socket
  Future<void> reconnect() async {
    if (_socket != null) {
      _socket!.connect();
    }
  }
}