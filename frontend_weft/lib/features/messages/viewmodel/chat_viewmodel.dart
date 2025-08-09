import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend_weft/features/messages/models/message_model.dart';
import 'package:frontend_weft/features/messages/service/socket_service.dart';

// Provider for chat messages for a specific conversation
final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, ChatState, int>((ref, receiverId) {
  final socket = ref.read(socketServiceProvider);
  final auth = ref.read(authViewModelProvider);
  return ChatMessagesNotifier(ref, socket, receiverId, auth);
});

// Provider for overall socket connection status
final socketConnectionProvider = StreamProvider<bool>((ref) {
  final socket = ref.read(socketServiceProvider);
  return socket.authStatusStream;
});

// Provider for socket errors
final socketErrorProvider = StreamProvider<String>((ref) {
  final socket = ref.read(socketServiceProvider);
  return socket.errorStream;
});

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final bool hasMoreMessages;
  final int currentPage;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.hasMoreMessages = true,
    this.currentPage = 1,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    bool? hasMoreMessages,
    int? currentPage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ChatMessagesNotifier extends StateNotifier<ChatState> {
  ChatMessagesNotifier(this.ref, this._socket, this.receiverId, this.authUser) : super(ChatState()) {
    _init();
  }

  final Ref ref;
  final SocketService _socket;
  final int receiverId;
  final dynamic authUser;
  
  StreamSubscription? _messageSubscription;
  StreamSubscription? _messageReceivedSubscription;
  StreamSubscription? _messageDeliveredSubscription;
  StreamSubscription? _messageReadSubscription;

  int? get currentUserId => authUser != null ? int.tryParse(authUser.id) : null;

  Future<void> _init() async {
    if (currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    try {
      state = state.copyWith(isLoading: true);
      await _socket.connect();
      _setupListeners();
      await loadMessages();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void _setupListeners() {
    // Listen for incoming messages
    _messageSubscription = _socket.messagesStream.listen((message) {
      if (_isRelevantMessage(message)) {
        _addMessage(message);
      }
    });

    // Listen for message status updates
    _messageReceivedSubscription = _socket.messageReceivedStream.listen((response) {
      _updateMessageStatus(response.messageUuid, MessageStatus.sent);
    });

    _messageDeliveredSubscription = _socket.messageDeliveredStream.listen((response) {
      _updateMessageStatus(response.messageUuid, MessageStatus.delivered);
    });

    _messageReadSubscription = _socket.messageReadStream.listen((response) {
      _updateMessageStatus(response.messageUuid, MessageStatus.read);
    });
  }

  bool _isRelevantMessage(ChatMessage message) {
    if (currentUserId == null) return false;
    
    return (message.senderId == currentUserId && message.receiverId == receiverId) ||
           (message.senderId == receiverId && message.receiverId == currentUserId);
  }

  void _addMessage(ChatMessage message) {
    final messages = List<ChatMessage>.from(state.messages);
    
    // Check if message already exists (avoid duplicates)
    final existingIndex = messages.indexWhere((m) => m.messageUuid == message.messageUuid);
    if (existingIndex != -1) {
      // Update existing message
      messages[existingIndex] = message;
    } else {
      // Add new message and sort by creation time
      messages.add(message);
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    
    state = state.copyWith(messages: messages);
  }

  void _updateMessageStatus(String messageUuid, MessageStatus status) {
    final messages = List<ChatMessage>.from(state.messages);
    final index = messages.indexWhere((m) => m.messageUuid == messageUuid);
    
    if (index != -1) {
      messages[index] = messages[index].copyWith(status: status);
      state = state.copyWith(messages: messages);
    }
  }

  Future<void> sendMessage(String content) async {
    if (currentUserId == null || content.trim().isEmpty) return;

    try {
      _socket.sendMessage(
        receiverId: receiverId,
        content: content.trim(),
        senderId: currentUserId!,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to send message: $e');
    }
  }

  Future<void> loadMessages({bool loadMore = false}) async {
    if (state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final page = loadMore ? state.currentPage + 1 : 1;
      await _socket.fetchMessages(page);
      
      state = state.copyWith(
        isLoading: false,
        currentPage: page,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void markMessageAsRead(String messageUuid, int senderId) {
    _socket.markMessageRead(senderId: senderId, messageUuid: messageUuid);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageReceivedSubscription?.cancel();
    _messageDeliveredSubscription?.cancel();
    _messageReadSubscription?.cancel();
    super.dispose();
  }
}