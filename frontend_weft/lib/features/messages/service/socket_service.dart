import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_local_repository.dart';
import 'package:frontend_weft/features/messages/models/message_model.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final repo = ref.read(authLocalRepositoryProvider);
  return SocketService(repo);
});

class SocketService {
  SocketService(this._authRepo);

  final AuthLocalRepository _authRepo;
  io.Socket? _socket;

  final _messageController = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messagesStream => _messageController.stream;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (isConnected) return;

    final token = await _authRepo.getAccessToken();
    if (token == null) throw Exception('Access token not found');

    print('🔌 Connecting to socket with token: ${token.substring(0, 10)}...');
    
    // Use base URL and let socket.io handle the rest
    final url = ServerConstants.baseUrl;
    print('🔗 Socket URL: $url');

    _socket = io.io(url, <String, dynamic>{
      'transports': ['polling'], // Use only polling for now
      'autoConnect': false,
      'forceNew': true,
      'timeout': 30000,
      'upgrade': false, // Disable websocket upgrade
      'rememberUpgrade': false,
    });

    _registerListeners();
    
    // Add connection event listeners before connecting
    _socket!.on('connect', (_) {
      print('🟢 Socket connected successfully!');
      print('🔑 Authenticating with token...');
      // Send token as raw string as expected by backend
      _socket!.emit('auth', token);
    });
    
    _socket!.on('connect_error', (error) {
      print('❌ Socket connection error: $error');
    });
    
    _socket!.on('disconnect', (reason) {
      print('🔴 Socket disconnected: $reason');
    });
    
    print('🚀 Initiating socket connection...');
    _socket!.connect();
  }

  void _registerListeners() {
    if (_socket == null) return;

    _socket!.on('auth_success', (_) {
      print('✅ Socket authenticated successfully');
    });

    _socket!.on('auth_error', (data) {
      print('❌ Socket auth error: $data');
    });

    _socket!.on('message', (data) {
      print('📨 Received message: $data');
      try {
        final msg = _mapToChatMessage(data);
        _messageController.add(msg);
      } catch (e) {
        print('❌ Error mapping message: $e');
      }
    });

    _socket!.on('message_received', (data) {
      print('📬 Message received acknowledgment: $data');
    });

    _socket!.on('message_delivered', (data) {
      print('📫 Message delivered: $data');
    });

    _socket!.on('message_read', (data) {
      print('👁️ Message read: $data');
    });

    _socket!.on('error', (data) {
      print('❌ Socket error: $data');
    });

    _socket!.on('disconnect', (data) {
      print('🔴 Socket disconnected: $data');
    });
  }

  ChatMessage _mapToChatMessage(dynamic data) {
    print('🔍 Mapping message data: $data');
    
    // Handle both Map and direct data
    final Map<String, dynamic> messageData = data is Map<String, dynamic> ? data : {};
    
    try {
      return ChatMessage(
        id: messageData['id'] is int 
            ? messageData['id'] 
            : (messageData['id'] != null ? int.tryParse(messageData['id'].toString()) : null),
        uuid: messageData['message_uuid']?.toString() ?? '',
        senderId: messageData['sender_id'] is int 
            ? messageData['sender_id'] 
            : int.parse(messageData['sender_id'].toString()),
        receiverId: messageData['receiver_id'] is int
            ? messageData['receiver_id']
            : (messageData['receiver_id'] != null
                ? int.parse(messageData['receiver_id'].toString())
                : 0),
        content: messageData['content']?.toString() ?? '',
        createdAt: messageData['created_at'] != null 
            ? DateTime.tryParse(messageData['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        delivered: messageData['delivered'] == true,
        read: messageData['read'] == true,
      );
    } catch (e) {
      print('❌ Error in _mapToChatMessage: $e');
      print('❌ Data was: $messageData');
      rethrow;
    }
  }

  void sendMessage({required int receiverId, required String content, required int senderId}) {
    if (!isConnected) {
      print('❌ Cannot send message - socket not connected');
      return;
    }
    
    final msg = ChatMessage.outgoing(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
    );

    print('📤 Sending message: receiverId=$receiverId, uuid=${msg.uuid}, content=$content');
    _socket!.emit('message', [receiverId.toString(), msg.uuid, content]);
    _messageController.add(msg); // Optimistic update
  }

  void markMessageRead({required int senderId, required String uuid}) {
    if (!isConnected) return;
    _socket!.emit('message_read', [senderId.toString(), uuid]);
  }

  Future<void> fetchMessages(int pageNumber) async {
    if (!isConnected) return;
    _socket!.emit('fetch_messages', [pageNumber.toString()]);
  }

  void dispose() {
    _messageController.close();
    _socket?.disconnect();
    _socket?.dispose();
  }
}
