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

  final _messageStreamController = StreamController<Message>.broadcast();
  final _messageStatusUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _chatUpdateStreamController = StreamController<Chat>.broadcast();
  final _typingStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _onlineStatusStreamController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Message> get messageStream => _messageStreamController.stream;
  Stream<Chat> get chatUpdateStream => _chatUpdateStreamController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingStreamController.stream;
  Stream<Map<String, dynamic>> get onlineStatusStream => _onlineStatusStreamController.stream;
  Stream<Map<String, dynamic>> get messageStatusUpdateStream => _messageStatusUpdateController.stream;
  String? get currentUserId => _currentUserId;

  Future<void> connect({required String serverUrl, required String userId, String? token}) async {
    _currentUserId = userId;
    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder().setTransports(['websocket']).disableAutoConnect().setExtraHeaders({
        if (token != null) 'Authorization': 'Bearer $token',
      }).build(),
    );
    _setupEventListeners(token: token);
    _socket!.connect();
  }

  void _setupEventListeners({String? token}) {
    _socket!.onConnect((_) {
      print('Socket connected successfully');
      _isConnected = true;
      if (token != null) _socket!.emit('auth', token);
    });
    _socket!.onDisconnect((_) => _isConnected = false);
    _socket!.onConnectError((error) => print('Socket connection error: $error'));

    _socket!.on('message', (data) {
      try {
        final message = Message.fromJson(data);
        _messageStreamController.add(message);
      } catch (e) {
        print('Error parsing incoming message: $e');
      }
    });

    _socket!.on('message_received', (data) {
      _messageStatusUpdateController.add({'status': MessageStatus.sent, 'data': data});
    });

    // Updated event name from 'delivered' to 'message_delivered'
    _socket!.on('message_delivered', (data) {
      _messageStatusUpdateController.add({'status': MessageStatus.delivered, 'data': data});
    });

    // Updated event name from 'message_status_update' to 'message_read'
    _socket!.on('message_read', (data) {
      _messageStatusUpdateController.add({'status': MessageStatus.read, 'data': data});
    });

    _socket!.on('error', (error) => print('Socket error: $error'));
  }

  // Updated to send receiver_id, uuid, and content
  void sendMessage({required String receiver_id, required String uuid, required String content}) {
    if (_isConnected) _socket!.emit('message', [receiver_id, uuid, content]);
  }

  // Updated to match the backend's expected payload for marking a message as read
  void markMessageAsRead({required String sender_id, required String messageUuid}) {
    if (_isConnected) _socket!.emit('message_read', [sender_id, messageUuid]);
  }
  
  void getUserChats() {
    if (_isConnected) _socket!.emit('get_user_chats', {'userId': _currentUserId});
  }

  void updateOnlineStatus({required bool isOnline}) {
  if (_isConnected) {
    _socket!.emit('update_online_status', {
      'userId': _currentUserId,
      'isOnline': isOnline,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}


  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _isConnected = false;
  }
}