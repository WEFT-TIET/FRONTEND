import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend_weft/features/messages/models/message_model.dart';
import 'package:frontend_weft/features/messages/repository/message_repository.dart';

final conversationsProvider = StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
  final repository = ref.read(messageRepositoryProvider);
  final auth = ref.read(authViewModelProvider);
  return ConversationsNotifier(repository, auth);
});

class ConversationsState {
  final List<ConversationSummary> conversations;
  final bool isLoading;
  final String? error;

  ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationsState copyWith({
    List<ConversationSummary>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ConversationsNotifier extends StateNotifier<ConversationsState> {
  ConversationsNotifier(this._repository, this.authUser) : super(ConversationsState()) {
    _init();
  }

  final MessageRepository _repository;
  final dynamic authUser;
  
  StreamSubscription? _messageSubscription;
  static const String _conversationsKey = 'cached_conversations';

  int? get currentUserId => authUser != null ? int.tryParse(authUser.id) : null;

  Future<void> _init() async {
    if (currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    try {
      state = state.copyWith(isLoading: true);
      
      // Load cached conversations first
      await _loadCachedConversations();
      
      // Connect to socket and listen for new messages
      await _repository.connect();
      _setupMessageListener();
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void _setupMessageListener() {
    _messageSubscription = _repository.messagesStream.listen((message) {
      _updateConversationWithMessage(message);
    });
  }

  Future<void> _loadCachedConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsString = prefs.getString(_conversationsKey);
      if (conversationsString == null) return;

      final conversationsJson = jsonDecode(conversationsString) as List;
      final conversations = conversationsJson
          .map((json) => ConversationSummary.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(conversations: conversations);
    } catch (e) {
      print('Error loading cached conversations: $e');
    }
  }

  Future<void> _cacheConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsJson = state.conversations.map((c) => c.toJson()).toList();
      await prefs.setString(_conversationsKey, jsonEncode(conversationsJson));
    } catch (e) {
      print('Error caching conversations: $e');
    }
  }

  void _updateConversationWithMessage(ChatMessage message) {
    if (currentUserId == null) return;

    final conversations = List<ConversationSummary>.from(state.conversations);
    
    // Determine the other user in the conversation
    final otherUserId = message.senderId == currentUserId ? message.receiverId : message.senderId;
    
    // Find existing conversation or create new one
    final existingIndex = conversations.indexWhere((c) => c.userId == otherUserId);
    
    if (existingIndex != -1) {
      // Update existing conversation
      final existing = conversations[existingIndex];
      conversations[existingIndex] = existing.copyWith(
        lastMessage: message,
        lastActivity: message.createdAt,
        unreadCount: message.senderId != currentUserId 
            ? existing.unreadCount + 1 
            : existing.unreadCount,
      );
    } else {
      // Create new conversation
      conversations.add(ConversationSummary(
        userId: otherUserId,
        userName: 'User $otherUserId', // In a real app, fetch user details
        lastMessage: message,
        lastActivity: message.createdAt,
        unreadCount: message.senderId != currentUserId ? 1 : 0,
      ));
    }

    // Sort by last activity
    conversations.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    
    state = state.copyWith(conversations: conversations);
    _cacheConversations();
  }

  void markConversationAsRead(int userId) {
    final conversations = List<ConversationSummary>.from(state.conversations);
    final index = conversations.indexWhere((c) => c.userId == userId);
    
    if (index != -1) {
      conversations[index] = conversations[index].copyWith(unreadCount: 0);
      state = state.copyWith(conversations: conversations);
      _cacheConversations();
    }
  }

  void addOrUpdateConversation(ConversationSummary conversation) {
    final conversations = List<ConversationSummary>.from(state.conversations);
    final existingIndex = conversations.indexWhere((c) => c.userId == conversation.userId);
    
    if (existingIndex != -1) {
      conversations[existingIndex] = conversation;
    } else {
      conversations.add(conversation);
    }
    
    // Sort by last activity
    conversations.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    
    state = state.copyWith(conversations: conversations);
    _cacheConversations();
  }

  void removeConversation(int userId) {
    final conversations = state.conversations.where((c) => c.userId != userId).toList();
    state = state.copyWith(conversations: conversations);
    _cacheConversations();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}