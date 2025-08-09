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

  // Stream controllers for different events
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _messageReceivedController = StreamController<MessageReceivedResponse>.broadcast();
  final _messageDeliveredController = StreamController<MessageDeliveredResponse>.broadcast();
  final _messageReadController = StreamController<MessageReadResponse>.broadcast();
  final _authStatusController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Public streams
  Stream<ChatMessage> get messagesStream => _messageController.stream;
  Stream<MessageReceivedResponse> get messageReceivedStream => _messageReceivedController.stream;
  Stream<MessageDeliveredResponse> get messageDeliveredStream => _messageDeliveredController.stream;
  Stream<MessageReadResponse> get messageReadStream => _messageReadController.stream;
  Stream<bool> get authStatusStream => _authStatusController.stream;
  Stream<String> get errorStream => _errorController.stream;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (isConnected) return;

    final token = await _authRepo.getAccessToken();
    if (token == null) throw Exception('Access token not found');

    print('🔌 Connecting to socket with token: ${token.substring(0, 10)}...');
    
    final url = ServerConstants.baseUrl;
    print('🔗 Socket URL: $url');

    // Dispose existing socket if any
    _socket?.dispose();
    _socket = null;

    // Reset auth status to false at start of connection
    _authStatusController.add(false);

    try {
      await _attemptConnectionWithTimeout(url, token);
    } catch (e) {
      print('❌ Connection failed: $e');
      _errorController.add('Connection failed: $e');
      _authStatusController.add(false);
      rethrow;
    }
  }

  Future<void> _attemptConnectionWithTimeout(String url, String token) async {
    final completer = Completer<void>();
    Timer? timeoutTimer;
    bool connectionCompleted = false;

    // Create socket with simplified configuration
    _socket = io.io(url, <String, dynamic>{
      'transports': ['polling'],
      'autoConnect': false,
      'forceNew': true,
      'timeout': 10000,
      'reconnection': false, // Disable auto-reconnection for manual control
      'upgrade': false,
      'rememberUpgrade': false,
    });

    // Set up timeout
    timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (!connectionCompleted) {
        print('❌ Connection timeout after 20 seconds');
        _socket?.disconnect();
        _socket?.dispose();
        _socket = null;
        _authStatusController.add(false);
        if (!completer.isCompleted) {
          completer.completeError('Connection timeout');
        }
      }
    });

    // Connection successful
    _socket!.on('connect', (_) {
      print('🟢 Socket connected successfully!');
      print('🔑 Authenticating with token...');
      _socket!.emit('auth', token);
    });

    // Authentication successful
    _socket!.on('auth_success', (_) {
      print('✅ Socket authenticated successfully');
      connectionCompleted = true;
      timeoutTimer?.cancel();
      _authStatusController.add(true);
      _registerListeners();
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    // Authentication failed
    _socket!.on('auth_error', (data) {
      print('❌ Socket auth error: $data');
      connectionCompleted = true;
      timeoutTimer?.cancel();
      _authStatusController.add(false);
      _errorController.add('Auth error: $data');
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      if (!completer.isCompleted) {
        completer.completeError('Authentication failed: $data');
      }
    });

    // Connection error
    _socket!.on('connect_error', (error) {
      print('❌ Socket connection error: $error');
      connectionCompleted = true;
      timeoutTimer?.cancel();
      _authStatusController.add(false);
      _errorController.add('Connection error: $error');
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      if (!completer.isCompleted) {
        completer.completeError('Connection error: $error');
      }
    });

    // General error
    _socket!.on('error', (error) {
      print('❌ Socket general error: $error');
      _errorController.add('Socket error: $error');
    });

    // Disconnection
    _socket!.on('disconnect', (reason) {
      print('🔴 Socket disconnected: $reason');
      _authStatusController.add(false);
    });

    print('🚀 Initiating socket connection...');
    _socket!.connect();

    // Wait for connection to complete or fail
    await completer.future;
  }

  void _registerListeners() {
    if (_socket == null) return;

    print('📡 Registering message event listeners...');

    // Message events
    _socket!.on('message', (data) {
      print('📨 Received message: $data');
      try {
        final msg = ChatMessage.fromBackend(data as Map<String, dynamic>);
        _messageController.add(msg);
      } catch (e) {
        print('❌ Error mapping message: $e');
        _errorController.add('Error mapping message: $e');
      }
    });

    _socket!.on('message_received', (data) {
      print('📬 Message received acknowledgment: $data');
      try {
        final response = MessageReceivedResponse.fromJson(data as Map<String, dynamic>);
        _messageReceivedController.add(response);
      } catch (e) {
        print('❌ Error mapping message_received: $e');
      }
    });

    _socket!.on('message_delivered', (data) {
      print('📫 Message delivered: $data');
      try {
        final response = MessageDeliveredResponse.fromJson(data as Map<String, dynamic>);
        _messageDeliveredController.add(response);
      } catch (e) {
        print('❌ Error mapping message_delivered: $e');
      }
    });

    _socket!.on('message_read', (data) {
      print('👁️ Message read: $data');
      try {
        final response = MessageReadResponse.fromJson(data as Map<String, dynamic>);
        _messageReadController.add(response);
      } catch (e) {
        print('❌ Error mapping message_read: $e');
      }
    });

    _socket!.on('fetch_error', (data) {
      print('❌ Fetch error: $data');
      _errorController.add('Fetch error: $data');
    });
  }

  void sendMessage({required int receiverId, required String content, required int senderId}) {
    if (!isConnected) {
      print('❌ Cannot send message - socket not connected');
      _errorController.add('Cannot send message - not connected');
      return;
    }
    
    final msg = ChatMessage.outgoing(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
    );

    print('📤 Sending message: receiverId=$receiverId, uuid=${msg.messageUuid}, content=$content');
    // Backend expects: receiverIDStr, uuidStr, content
    _socket!.emit('message', [receiverId.toString(), msg.messageUuid, content]);
    
    // Add optimistic update
    _messageController.add(msg);
  }

  void markMessageRead({required int senderId, required String messageUuid}) {
    if (!isConnected) {
      print('❌ Cannot mark message read - socket not connected');
      return;
    }
    print('👁️ Marking message read: senderId=$senderId, uuid=$messageUuid');
    // Backend expects: senderIDStr, uuidStr
    _socket!.emit('message_read', [senderId.toString(), messageUuid]);
  }

  Future<void> fetchMessages(int pageNumber) async {
    if (!isConnected) {
      print('❌ Cannot fetch messages - socket not connected');
      return;
    }
    print('📥 Fetching messages page: $pageNumber');
    // Backend expects: pageStr
    _socket!.emit('fetch_messages', [pageNumber.toString()]);
  }

  void disconnect() {
    print('🔌 Manually disconnecting socket');
    _socket?.disconnect();
    _authStatusController.add(false);
  }

  // Test connection with different configurations
  Future<void> testConnection() async {
    final token = await _authRepo.getAccessToken();
    if (token == null) throw Exception('Access token not found');

    final url = ServerConstants.baseUrl;
    print('🧪 Testing socket connection to: $url');

    // Test with minimal configuration first
    final testSocket = io.io(url, <String, dynamic>{
      'transports': ['polling'],
      'autoConnect': false,
      'timeout': 10000,
      'upgrade': false,
    });

    testSocket.on('connect', (_) {
      print('✅ Test connection successful!');
      testSocket.emit('auth', token);
    });

    testSocket.on('auth_success', (_) {
      print('✅ Test authentication successful!');
      testSocket.disconnect();
    });

    testSocket.on('auth_error', (data) {
      print('❌ Test authentication failed: $data');
      testSocket.disconnect();
    });

    testSocket.on('connect_error', (error) {
      print('❌ Test connection failed: $error');
    });

    testSocket.connect();

    // Clean up after 15 seconds
    Timer(const Duration(seconds: 15), () {
      testSocket.disconnect();
      testSocket.dispose();
    });
  }

  // Force reconnect with fresh configuration
  Future<void> forceReconnect() async {
    print('🔄 Force reconnecting socket...');
    
    // Disconnect and dispose current socket
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    
    // Reset auth status
    _authStatusController.add(false);
    
    // Wait a moment before reconnecting
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Reconnect
    await connect();
  }

  void dispose() {
    print('🗑️ Disposing socket service...');
    _messageController.close();
    _messageReceivedController.close();
    _messageDeliveredController.close();
    _messageReadController.close();
    _authStatusController.close();
    _errorController.close();
    _socket?.disconnect();
    _socket?.dispose();
  }
}