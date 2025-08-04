import 'dart:async';
import 'package:uuid/uuid.dart';
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

  // --- FIXED: Added getter to expose the currentUserId from SocketService ---
  String? get currentUserId => _socketService.currentUserId;

  // Initialize service
  Future<void> initialize({
    required String serverUrl,
    required String userId,
    String? token,
  }) async {
    try {
      await _socketService.connect(
        serverUrl: serverUrl,
        userId: userId,
        token: token,
      );
      _setupSocketListeners();
      await _loadInitialData();
    } catch (e) {
      print('Error initializing MessageService: $e');
      rethrow;
    }
  }

  // Set up socket event listeners
  void _setupSocketListeners() {
    // Listen for new messages
    _socketService.messageStream.listen((message) {
      _handleNewMessage(message);
    });

    // --- WIRED UP: Listen for real status updates from the server ---
    _socketService.messageStatusUpdateStream.listen((update) {
      _handleMessageStatusUpdate(update);
    });

    // Listen for chat updates
    _socketService.chatUpdateStream.listen((chat) {
      _handleChatUpdate(chat);
    });

    // Listen for typing indicators
    _socketService.typingStream.listen((data) {
      _handleTypingIndicator(data);
    });

    // Listen for online status updates
    _socketService.onlineStatusStream.listen((data) {
      _handleOnlineStatusUpdate(data);
    });
  }

  // Handles real status updates for messages (e.g., sent, delivered)
  void _handleMessageStatusUpdate(Map<String, dynamic> update) {
    final status = update['status'] as MessageStatus;
    final data = update['data'] as Map<String, dynamic>;
    final messageUuid = data['message_uuid'] as String?;

    if (messageUuid == null) return;

    String? chatId;
    int? messageIndex;

    // Find the message by its UUID across all chats
    for (var entry in _chatMessages.entries) {
      final index = entry.value.indexWhere((m) => m.id == messageUuid);
      if (index != -1) {
        chatId = entry.key;
        messageIndex = index;
        break;
      }
    }

    if (chatId != null && messageIndex != null) {
      // Update the message status
      _chatMessages[chatId]![messageIndex] =
          _chatMessages[chatId]![messageIndex].copyWith(status: status);
      // Notify the UI
      _messagesController.add(_chatMessages[chatId]!);
    }
  }

  // Handle new incoming message
  void _handleNewMessage(Message message) {
    // Determine the chat ID from the message sender/receiver
    final chatId = message.senderId == currentUserId
        ? message.receiverId
        : message.senderId;

    if (!_chatMessages.containsKey(chatId)) {
      _chatMessages[chatId] = [];
    }
    _chatMessages[chatId]!.add(message);

    // --- FIXED: Removed inefficient sorting on every new message ---
    // The list can be sorted once on display if needed.

    // Update the parent chat object with the last message info
    if (_chats.containsKey(chatId)) {
      _chats[chatId] = _chats[chatId]!.copyWith(
        lastMessage: message.content,
        lastMessageTime: message.timestamp,
      );
    }

    // Notify UI of the new message and chat list update
    _messagesController.add(_chatMessages[chatId]!);
    _chatsController.add(getAllChats());
  }

  // Handle chat update (e.g., user profile change)
  void _handleChatUpdate(Chat chat) {
    _chats[chat.id] = chat;
    _chatsController.add(getAllChats());
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

  // Handle online status update for users
  void _handleOnlineStatusUpdate(Map<String, dynamic> data) {
    final userId = data['userId'] as String;
    final isOnline = data['isOnline'] as bool;
    final lastSeen = data['lastSeen'] != null ? DateTime.tryParse(data['lastSeen']) : null;

    if (_chats.containsKey(userId)) {
      _chats[userId] = _chats[userId]!.copyWith(
        isOnline: isOnline,
        lastSeen: lastSeen,
      );
      _chatsController.add(getAllChats());
    }
  }

  // Load initial data from the server
  Future<void> _loadInitialData() async {
    // --- CLEANED: No dummy data, just request real data ---
    _socketService.getUserChats();
  }

  // Send a new message
  Future<void> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    try {
      final messageId = const Uuid().v4();

      // Optimistically create the message with 'sending' status
      final message = Message(
        id: messageId,
        senderId: currentUserId!,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
        type: MessageType.text, // Assuming text type for now
        status: MessageStatus.sending,
      );

      // Add to local storage immediately for a snappy UI
      if (!_chatMessages.containsKey(receiverId)) {
        _chatMessages[receiverId] = [];
      }
      _chatMessages[receiverId]!.add(message);
      _messagesController.add(_chatMessages[receiverId]!);

      // Send the message via the socket
      _socketService.sendMessage(
        receiverId: receiverId,
        content: content,
        // messageId: messageId, // Consider sending the ID to map server responses easily
      );

      // --- FIXED: Removed simulated `Future.delayed` and local status update ---
      // The `_handleMessageStatusUpdate` method now handles this automatically
      // when a real response comes from the server.

    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Get a snapshot of messages for a specific chat
  List<Message> getMessagesForChat(String chatId) {
    return _chatMessages[chatId] ?? [];
  }

  // Get a snapshot of all chats, sorted by the most recent message
  List<Chat> getAllChats() {
    final chatList = _chats.values.toList();
    chatList.sort((a, b) =>
        (b.lastMessageTime ?? DateTime(0))
            .compareTo(a.lastMessageTime ?? DateTime(0)));
    return chatList;
  }

  // --- The rest of the methods are primarily pass-through calls to the SocketService ---

  void joinChatRoom(String chatId) => _socketService.joinChatRoom(chatId);
  void leaveChatRoom(String chatId) => _socketService.leaveChatRoom(chatId);

  void sendTypingIndicator({required String chatId, required bool isTyping}) {
    _socketService.sendTypingIndicator(chatId: chatId, isTyping: isTyping);
  }

  void markMessageAsRead(String messageId) => _socketService.markMessageAsRead(messageId);

  Future<void> handleUserAction(UserActionData actionData) async {
    try {
      switch (actionData.action) {
        case UserAction.block:
          _socketService.blockUser(
              userId: actionData.userId,
              reason: actionData.reason ?? 'No reason provided');
          break;
        case UserAction.report:
          _socketService.reportUser(
              userId: actionData.userId,
              reason: actionData.reason ?? 'No reason provided');
          break;
        case UserAction.deleteChat:
          _chatMessages.remove(actionData.chatId);
          _chats.remove(actionData.chatId);
          _chatsController.add(getAllChats());
          // Consider sending a 'delete_chat' event to the server as well
          break;
        default:
          // Handle other cases like mute/unmute if they have server-side logic
          break;
      }
    } catch (e) {
      print('Error handling user action: $e');
      rethrow;
    }
  }
  
  void updateOnlineStatus(bool isOnline) => _socketService.updateOnlineStatus(isOnline);

  void dispose() {
    _messagesController.close();
    _chatsController.close();
    _typingController.close();
    _socketService.disconnect();
  }
}