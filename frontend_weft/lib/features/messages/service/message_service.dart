// services/message_service.dart
import 'dart:async';
import '../models/message.dart';
import '../models/chat.dart';
import '../models/user_action.dart';
import 'socket_service.dart';

class MessageService {
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal();

  final SocketService _socketService = SocketService();
  
  // Local data storage
  final Map<String, List<Message>> _chatMessages = {};
  final Map<String, Chat> _chats = {};
  final Set<String> _typingUsers = {};
  
  // Stream controllers for UI updates
  final _messagesController = StreamController<List<Message>>.broadcast();
  final _chatsController = StreamController<List<Chat>>.broadcast();
  final _typingController = StreamController<Set<String>>.broadcast();
  
  // Streams for UI
  Stream<List<Message>> get messagesStream => _messagesController.stream;
  Stream<List<Chat>> get chatsStream => _chatsController.stream;
  Stream<Set<String>> get typingStream => _typingController.stream;

  // Initialize service
  Future<void> initialize({
    required String serverUrl,
    required String userId,
    String? token,
  }) async {
    try {
      // Connect to socket
      await _socketService.connect(
        serverUrl: serverUrl,
        userId: userId,
        token: token,
      );
      
      // Set up socket listeners
      _setupSocketListeners();
      
      // Load initial data
      await _loadInitialData();
      
    } catch (e) {
      print('Error initializing MessageService: $e');
      rethrow;
    }
  }

  // Set up socket event listeners
  void _setupSocketListeners() {
    // Listen for new messages
    _socketService.messageStream?.listen((message) {
      _handleNewMessage(message);
    });

    // Listen for chat updates
    _socketService.chatUpdateStream?.listen((chat) {
      _handleChatUpdate(chat);
    });

    // Listen for typing indicators
    _socketService.typingStream?.listen((data) {
      _handleTypingIndicator(data);
    });

    // Listen for online status updates
    _socketService.onlineStatusStream?.listen((data) {
      _handleOnlineStatusUpdate(data);
    });
  }

  // Handle new message
  void _handleNewMessage(Message message) {
    final chatId = message.senderId == _socketService.currentUserId 
        ? message.receiverId 
        : message.senderId;
    
    // Add message to local storage
    if (!_chatMessages.containsKey(chatId)) {
      _chatMessages[chatId] = [];
    }
    _chatMessages[chatId]!.add(message);
    
    // Sort messages by timestamp
    _chatMessages[chatId]!.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Update chat's last message
    if (_chats.containsKey(chatId)) {
      _chats[chatId] = _chats[chatId]!.copyWith(
        lastMessage: message.content,
        lastMessageTime: message.timestamp,
      );
    }
    
    // Notify UI
    _messagesController.add(_chatMessages[chatId]!);
    _chatsController.add(_chats.values.toList());
  }

  // Handle chat update
  void _handleChatUpdate(Chat chat) {
    _chats[chat.id] = chat;
    _chatsController.add(_chats.values.toList());
  }

  // Handle typing indicator
  void _handleTypingIndicator(Map<String, dynamic> data) {
    final userId = data['userId'] as String;
    final isTyping = data['isTyping'] as bool;
    
    if (isTyping) {
      _typingUsers.add(userId);
    } else {
      _typingUsers.remove(userId);
    }
    
    _typingController.add(_typingUsers);
  }

  // Handle online status update
  void _handleOnlineStatusUpdate(Map<String, dynamic> data) {
    final userId = data['userId'] as String;
    final isOnline = data['isOnline'] as bool;
    final lastSeen = data['lastSeen'] as DateTime?;
    
    if (_chats.containsKey(userId)) {
      _chats[userId] = _chats[userId]!.copyWith(
        isOnline: isOnline,
        lastSeen: lastSeen,
      );
      _chatsController.add(_chats.values.toList());
    }
  }

  // Load initial data
  Future<void> _loadInitialData() async {
    // Request user's chats from server
    _socketService.getUserChats();
    
    // Add some dummy data for testing
    _addDummyData();
  }

  // Add dummy data for testing
  void _addDummyData() {
    final dummyChats = [
      Chat(
        id: '1',
        name: 'Alice Johnson',
        username: '@alice',
        profilePic: 'https://randomuser.me/api/portraits/women/1.jpg',
        lastMessage: 'Hey! How are you doing today?',
        lastMessageTime: DateTime.now().subtract(Duration(minutes: 5)),
        unreadCount: 2,
      ),
      Chat(
        id: '2',
        name: 'Bob Smith',
        username: '@bob',
        profilePic: 'https://randomuser.me/api/portraits/men/2.jpg',
        lastMessage: 'Let\'s catch up later this evening.',
        lastMessageTime: DateTime.now().subtract(Duration(minutes: 45)),
        unreadCount: 0,
        lastSeen: DateTime.now().subtract(Duration(hours: 2)),
      ),
    ];

    for (final chat in dummyChats) {
      _chats[chat.id] = chat;
    }

    _chatsController.add(_chats.values.toList());
  }

  // Send message
  Future<void> sendMessage({
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      // Create local message with sending status
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _socketService.currentUserId!,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
        type: type,
        status: MessageStatus.sending,
      );

      // Add to local storage immediately
      if (!_chatMessages.containsKey(receiverId)) {
        _chatMessages[receiverId] = [];
      }
      _chatMessages[receiverId]!.add(message);
      _messagesController.add(_chatMessages[receiverId]!);

      // Send via socket
      _socketService.sendMessage(
        receiverId: receiverId,
        content: content,
        type: type,
      );

      // Simulate status update (replace with actual socket response)
      await Future.delayed(Duration(milliseconds: 500));
      final index = _chatMessages[receiverId]!.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _chatMessages[receiverId]![index] = message.copyWith(
          status: MessageStatus.sent,
        );
        _messagesController.add(_chatMessages[receiverId]!);
      }

    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Get messages for a chat
  List<Message> getMessagesForChat(String chatId) {
    return _chatMessages[chatId] ?? [];
  }

  // Get all chats
  List<Chat> getAllChats() {
    return _chats.values.toList()
      ..sort((a, b) => (b.lastMessageTime ?? DateTime(0))
          .compareTo(a.lastMessageTime ?? DateTime(0)));
  }

  // Join chat room
  void joinChatRoom(String chatId) {
    _socketService.joinChatRoom(chatId);
  }

  // Leave chat room
  void leaveChatRoom(String chatId) {
    _socketService.leaveChatRoom(chatId);
  }

  // Send typing indicator
  void sendTypingIndicator({
    required String chatId,
    required bool isTyping,
  }) {
    _socketService.sendTypingIndicator(
      chatId: chatId,
      isTyping: isTyping,
    );
  }

  // Mark message as read
  void markMessageAsRead(String messageId) {
    _socketService.markMessageAsRead(messageId);
  }

  // Handle user actions
  Future<void> handleUserAction(UserActionData actionData) async {
    try {
      switch (actionData.action) {
        case UserAction.block:
          _socketService.blockUser(
            userId: actionData.userId,
            reason: actionData.reason ?? 'No reason provided',
          );
          break;
        case UserAction.report:
          _socketService.reportUser(
            userId: actionData.userId,
            reason: actionData.reason ?? 'No reason provided',
          );
          break;
        case UserAction.deleteChat:
          _chatMessages.remove(actionData.chatId);
          _chats.remove(actionData.chatId);
          _chatsController.add(_chats.values.toList());
          break;
        case UserAction.muteChat:
          if (_chats.containsKey(actionData.chatId)) {
            // Handle mute logic (you might want to add a muted field to Chat model)
            print('Chat muted: ${actionData.chatId}');
          }
          break;
        case UserAction.unmuteChat:
          if (_chats.containsKey(actionData.chatId)) {
            // Handle unmute logic
            print('Chat unmuted: ${actionData.chatId}');
          }
          break;
        case UserAction.viewProfile:
          // Handle view profile (usually just navigation)
          print('View profile: ${actionData.userId}');
          break;
      }
    } catch (e) {
      print('Error handling user action: $e');
      rethrow;
    }
  }

  // Search chats
  List<Chat> searchChats(String query) {
    final lowerQuery = query.toLowerCase();
    return _chats.values
        .where((chat) =>
            chat.name.toLowerCase().contains(lowerQuery) ||
            chat.username.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // Update online status
  void updateOnlineStatus(bool isOnline) {
    _socketService.updateOnlineStatus(isOnline);
  }

  // Dispose service
  void dispose() {
    _messagesController.close();
    _chatsController.close();
    _typingController.close();
    _socketService.disconnect();
  }
}
