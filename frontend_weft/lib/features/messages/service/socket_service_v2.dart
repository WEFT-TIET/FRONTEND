import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_local_repository.dart';
import 'package:frontend_weft/features/messages/models/message_model.dart';

final socketServiceV2Provider = Provider<SocketServiceV2>((ref) {
  final repo = ref.read(authLocalRepositoryProvider);
  return SocketServiceV2(repo);
});

class SocketServiceV2 {
  SocketServiceV2(this._authRepo);

  final AuthLocalRepository _authRepo;
  io.Socket? _socket;

  // Stream controllers for different events
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _messageReceivedController = StreamController<MessageReceivedResponse>.broadcast();
  final _messageDeliveredController = StreamController<MessageDeliveredResponse>.broadcast();
  final _messageReadController = StreamController<MessageReadResponse>.broadcast();
  final _authStatusController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _debugController = StreamController<String>.broadcast();

  // Public streams
  Stream<ChatMessage> get messagesStream => _messageController.stream;
  Stream<MessageReceivedResponse> get messageReceivedStream => _messageReceivedController.stream;
  Stream<MessageDeliveredResponse> get messageDeliveredStream => _messageDeliveredController.stream;
  Stream<MessageReadResponse> get messageReadStream => _messageReadController.stream;
  Stream<bool> get authStatusStream => _authStatusController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<String> get debugStream => _debugController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void _debug(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final debugMessage = '$timestamp: $message';
    print('🐛 $debugMessage');
    _debugController.add(debugMessage);
  }

  // Test server connectivity first
  Future<bool> testServerConnectivity() async {
    _debug('Testing server connectivity...');
    
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      
      final uri = Uri.parse(ServerConstants.baseUrl);
      final request = await client.getUrl(uri);
      final response = await request.close();
      
      _debug('Server response: ${response.statusCode}');
      client.close();
      
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      _debug('Server connectivity test failed: $e');
      return false;
    }
  }

  // Test socket.io endpoint specifically
  Future<bool> testSocketIOEndpoint() async {
    _debug('Testing Socket.IO endpoint...');
    
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      
      // Test the socket.io polling endpoint
      final uri = Uri.parse('${ServerConstants.baseUrl}/socket.io/?EIO=4&transport=polling');
      final request = await client.getUrl(uri);
      request.headers.set('Accept', '*/*');
      request.headers.set('User-Agent', 'Flutter-SocketIO-Client');
      
      final response = await request.close();
      _debug('Socket.IO endpoint response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(const Utf8Decoder()).join();
        _debug('Socket.IO response body preview: ${responseBody.substring(0, responseBody.length > 100 ? 100 : responseBody.length)}...');
      }
      
      client.close();
      return response.statusCode == 200;
    } catch (e) {
      _debug('Socket.IO endpoint test failed: $e');
      return false;
    }
  }

  Future<void> connect() async {
    if (isConnected) {
      _debug('Already connected, skipping...');
      return;
    }

    _debug('Starting connection process...');

    // Step 1: Test server connectivity
    final serverReachable = await testServerConnectivity();
    if (!serverReachable) {
      throw Exception('Server is not reachable at ${ServerConstants.baseUrl}');
    }

    // Step 2: Test Socket.IO endpoint
    final socketIOReachable = await testSocketIOEndpoint();
    if (!socketIOReachable) {
      _debug('Socket.IO endpoint not responding correctly, but attempting connection anyway...');
    }

    // Step 3: Get authentication token
    final token = await _authRepo.getAccessToken();
    if (token == null) {
      throw Exception('Access token not found');
    }

    _debug('Token available, length: ${token.length}');

    // Step 4: Try connection with multiple strategies
    await _attemptConnection(token);
  }

  Future<void> _attemptConnection(String token) async {
    final url = ServerConstants.baseUrl;
    _debug('Attempting connection to: $url');

    // Dispose existing socket
    _socket?.dispose();
    _socket = null;

    // Strategy 1: Polling only, no upgrade
    _debug('Trying Strategy 1: Polling only');
    if (await _tryConnectionStrategy(url, {
      'transports': ['polling'],
      'upgrade': false,
      'autoConnect': false,
      'timeout': 10000,
      'forceNew': true,
      'reconnection': false,
    }, token, 'Strategy 1')) {
      return;
    }

    // Strategy 2: Polling with different EIO version
    _debug('Trying Strategy 2: Polling with EIO3');
    if (await _tryConnectionStrategy(url, {
      'transports': ['polling'],
      'upgrade': false,
      'autoConnect': false,
      'timeout': 10000,
      'forceNew': true,
      'reconnection': false,
      'forceBase64': true,
    }, token, 'Strategy 2')) {
      return;
    }

    // Strategy 3: WebSocket only
    _debug('Trying Strategy 3: WebSocket only');
    if (await _tryConnectionStrategy(url, {
      'transports': ['websocket'],
      'autoConnect': false,
      'timeout': 10000,
      'forceNew': true,
      'reconnection': false,
    }, token, 'Strategy 3')) {
      return;
    }

    // Strategy 4: Both transports
    _debug('Trying Strategy 4: Both transports');
    if (await _tryConnectionStrategy(url, {
      'transports': ['polling', 'websocket'],
      'upgrade': true,
      'autoConnect': false,
      'timeout': 10000,
      'forceNew': true,
      'reconnection': false,
    }, token, 'Strategy 4')) {
      return;
    }

    throw Exception('All connection strategies failed');
  }

  Future<bool> _tryConnectionStrategy(
    String url,
    Map<String, dynamic> options,
    String token,
    String strategyName,
  ) async {
    io.Socket? testSocket;
    
    try {
      testSocket = io.io(url, options);
      
      final completer = Completer<bool>();
      Timer? timeoutTimer;
      bool connected = false;
      bool authenticated = false;
      
      testSocket.on('connect', (_) {
        _debug('$strategyName: Connected! Attempting authentication...');
        connected = true;
        testSocket!.emit('auth', token);
      });
      
      testSocket.on('auth_success', (_) {
        _debug('$strategyName: Authentication successful!');
        authenticated = true;
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      });
      
      testSocket.on('auth_error', (data) {
        _debug('$strategyName: Authentication failed: $data');
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });
      
      testSocket.on('connect_error', (error) {
        _debug('$strategyName: Connection error: $error');
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });
      
      testSocket.on('error', (error) {
        _debug('$strategyName: Socket error: $error');
      });
      
      // Set timeout
      timeoutTimer = Timer(const Duration(seconds: 15), () {
        _debug('$strategyName: Timeout reached');
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });
      
      testSocket.connect();
      
      final success = await completer.future;
      timeoutTimer?.cancel();
      
      if (success && connected && authenticated) {
        _debug('$strategyName: Strategy successful! Using this connection.');
        _socket = testSocket;
        _registerListeners();
        _authStatusController.add(true);
        return true;
      } else {
        _debug('$strategyName: Strategy failed');
        testSocket.disconnect();
        testSocket.dispose();
        return false;
      }
      
    } catch (e) {
      _debug('$strategyName: Exception: $e');
      testSocket?.disconnect();
      testSocket?.dispose();
      return false;
    }
  }

  void _registerListeners() {
    if (_socket == null) return;

    _debug('Registering socket event listeners...');

    // Message events
    _socket!.on('message', (data) {
      _debug('Received message: $data');
      try {
        final msg = ChatMessage.fromBackend(data as Map<String, dynamic>);
        _messageController.add(msg);
      } catch (e) {
        _debug('Error mapping message: $e');
        _errorController.add('Error mapping message: $e');
      }
    });

    _socket!.on('message_received', (data) {
      _debug('Message received acknowledgment: $data');
      try {
        final response = MessageReceivedResponse.fromJson(data as Map<String, dynamic>);
        _messageReceivedController.add(response);
      } catch (e) {
        _debug('Error mapping message_received: $e');
      }
    });

    _socket!.on('message_delivered', (data) {
      _debug('Message delivered: $data');
      try {
        final response = MessageDeliveredResponse.fromJson(data as Map<String, dynamic>);
        _messageDeliveredController.add(response);
      } catch (e) {
        _debug('Error mapping message_delivered: $e');
      }
    });

    _socket!.on('message_read', (data) {
      _debug('Message read: $data');
      try {
        final response = MessageReadResponse.fromJson(data as Map<String, dynamic>);
        _messageReadController.add(response);
      } catch (e) {
        _debug('Error mapping message_read: $e');
      }
    });

    _socket!.on('error', (data) {
      _debug('Socket error: $data');
      _errorController.add('Socket error: $data');
    });

    _socket!.on('fetch_error', (data) {
      _debug('Fetch error: $data');
      _errorController.add('Fetch error: $data');
    });

    _socket!.on('disconnect', (reason) {
      _debug('Socket disconnected: $reason');
      _authStatusController.add(false);
    });

    _socket!.on('connect_error', (error) {
      _debug('Connection error: $error');
      _errorController.add('Connection error: $error');
    });
  }

  void sendMessage({required int receiverId, required String content, required int senderId}) {
    if (!isConnected) {
      _debug('Cannot send message - socket not connected');
      _errorController.add('Cannot send message - not connected');
      return;
    }
    
    final msg = ChatMessage.outgoing(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
    );

    _debug('Sending message: receiverId=$receiverId, uuid=${msg.messageUuid}, content=$content');
    // Backend expects: receiverIDStr, uuidStr, content
    _socket!.emit('message', [receiverId.toString(), msg.messageUuid, content]);
    
    // Add optimistic update
    _messageController.add(msg);
  }

  void markMessageRead({required int senderId, required String messageUuid}) {
    if (!isConnected) {
      _debug('Cannot mark message read - socket not connected');
      return;
    }
    _debug('Marking message read: senderId=$senderId, uuid=$messageUuid');
    // Backend expects: senderIDStr, uuidStr
    _socket!.emit('message_read', [senderId.toString(), messageUuid]);
  }

  Future<void> fetchMessages(int pageNumber) async {
    if (!isConnected) {
      _debug('Cannot fetch messages - socket not connected');
      return;
    }
    _debug('Fetching messages page: $pageNumber');
    // Backend expects: pageStr
    _socket!.emit('fetch_messages', [pageNumber.toString()]);
  }

  void disconnect() {
    _debug('Manually disconnecting socket');
    _socket?.disconnect();
    _authStatusController.add(false);
  }

  Future<void> forceReconnect() async {
    _debug('Force reconnecting socket...');
    
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
    _debug('Disposing socket service...');
    _messageController.close();
    _messageReceivedController.close();
    _messageDeliveredController.close();
    _messageReadController.close();
    _authStatusController.close();
    _errorController.close();
    _debugController.close();
    _socket?.disconnect();
    _socket?.dispose();
  }
}