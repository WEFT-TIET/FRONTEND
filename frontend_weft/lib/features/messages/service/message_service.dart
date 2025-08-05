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
  final Map<String, List<Message>> _chatMessages = {};
  final Map<String, Chat> _chats = {};
  final Set<String> _typingUsers = {};

  final _messagesController = StreamController<List<Message>>.broadcast();
  final _chatsController = StreamController<List<Chat>>.broadcast();
  final _typingController = StreamController<Set<String>>.broadcast();

  Stream<List<Message>> get messagesStream => _messagesController.stream;
  Stream<List<Chat>> get chatsStream => _chatsController.stream;
  Stream<Set<String>> get typingStream => _typingController.stream;
  String? get currentUserId => _socketService.currentUserId;

  Future<void> initialize({
    required String serverUrl,
    required String userId,
    String? token,
  }) async {
    try {
      await _socketService.connect(serverUrl: serverUrl, userId: userId, token: token);
      _setupSocketListeners();
      _loadInitialData();
    } catch (e) {
      print('Error initializing MessageService: $e');
      rethrow;
    }
  }

  void _setupSocketListeners() {
    _socketService.messageStream.listen(_handleNewMessage);
    _socketService.messageStatusUpdateStream.listen(_handleMessageStatusUpdate);
    _socketService.chatUpdateStream.listen(_handleChatUpdate);
    _socketService.typingStream.listen(_handleTypingIndicator);
    _socketService.onlineStatusStream.listen(_handleOnlineStatusUpdate);
  }

  void _handleMessageStatusUpdate(Map<String, dynamic> update) {
    final status = update['status'] as MessageStatus;
    final data = update['data'] as Map<String, dynamic>;
    final messageUuid = data['message_uuid'] as String?;

    if (messageUuid == null) return;

    for (var entry in _chatMessages.entries) {
      final index = entry.value.indexWhere((m) => m.id == messageUuid);
      if (index != -1) {
        final chatId = entry.key;
        _chatMessages[chatId]![index] = _chatMessages[chatId]![index].copyWith(status: status);
        _messagesController.add(_chatMessages[chatId]!);
        break;
      }
    }
  }
  
  void updateOnlineStatus(bool isOnline) {
  _socketService.updateOnlineStatus(isOnline: isOnline);
}


  void _handleNewMessage(Message message) {
    final chatId = message.sender_id == currentUserId ? message.receiver_id : message.sender_id;
    if (!_chatMessages.containsKey(chatId)) {
      _chatMessages[chatId] = [];
    }
    _chatMessages[chatId]!.add(message);

    if (_chats.containsKey(chatId)) {
      _chats[chatId] = _chats[chatId]!.copyWith(
        lastMessage: message.content,
        lastMessageTime: message.timestamp,
      );
    }
    _messagesController.add(_chatMessages[chatId]!);
    _chatsController.add(getAllChats());
  }

  void _handleChatUpdate(Chat chat) {
    _chats[chat.id] = chat;
    _chatsController.add(getAllChats());
  }

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

  void _handleOnlineStatusUpdate(Map<String, dynamic> data) {
    final userId = data['userId'] as String;
    final isOnline = data['isOnline'] as bool;
    final lastSeen = data['lastSeen'] != null ? DateTime.tryParse(data['lastSeen']) : null;

    if (_chats.containsKey(userId)) {
      _chats[userId] = _chats[userId]!.copyWith(isOnline: isOnline, lastSeen: lastSeen);
      _chatsController.add(getAllChats());
    }
  }

  void _loadInitialData() {
    _socketService.getUserChats();
  }

  Future<void> sendMessage({required String receiver_id, required String content}) async {
    final messageId = const Uuid().v4();
    final message = Message(
      id: messageId,
      sender_id: currentUserId!,
      receiver_id: receiver_id,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    if (!_chatMessages.containsKey(receiver_id)) {
      _chatMessages[receiver_id] = [];
    }
    _chatMessages[receiver_id]!.add(message);
    _messagesController.add(_chatMessages[receiver_id]!);

    // Match the new backend payload: [receiver_id, uuid, content]
    _socketService.sendMessage(
      receiver_id: receiver_id,
      uuid: messageId,
      content: content,
    );
  }

  List<Message> getMessagesForChat(String chatId) => _chatMessages[chatId] ?? [];

  List<Chat> getAllChats() {
    final chatList = _chats.values.toList();
    chatList.sort((a, b) => (b.lastMessageTime ?? DateTime(0)).compareTo(a.lastMessageTime ?? DateTime(0)));
    return chatList;
  }

  void markMessageAsRead({required String sender_id, required String messageUuid}) {
    _socketService.markMessageAsRead(sender_id: sender_id, messageUuid: messageUuid);
  }

  void dispose() {
    _messagesController.close();
    _chatsController.close();
    _typingController.close();
    _socketService.disconnect();
  }
}