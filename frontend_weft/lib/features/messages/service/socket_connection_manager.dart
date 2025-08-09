import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_local_repository.dart';

final socketConnectionManagerProvider = Provider<SocketConnectionManager>((ref) {
  final repo = ref.read(authLocalRepositoryProvider);
  return SocketConnectionManager(repo);
});

class SocketConnectionManager {
  SocketConnectionManager(this._authRepo);

  final AuthLocalRepository _authRepo;
  final List<String> _connectionLogs = [];

  List<String> get connectionLogs => List.unmodifiable(_connectionLogs);

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '$timestamp: $message';
    _connectionLogs.add(logMessage);
    print('🔌 $logMessage');
  }

  void clearLogs() {
    _connectionLogs.clear();
  }

  // Try to establish connection with different strategies
  Future<io.Socket?> establishConnection() async {
    final token = await _authRepo.getAccessToken();
    if (token == null) {
      _log('ERROR: No access token available');
      return null;
    }

    _log('Starting connection establishment process...');
    
    // Strategy 1: Try with polling only (most compatible)
    var socket = await _tryConnectionStrategy('Polling Only', {
      'transports': ['polling'],
      'upgrade': false,
      'autoConnect': false,
      'timeout': 10000,
      'forceNew': true,
    }, token);
    
    if (socket != null) return socket;

    // Strategy 2: Try with different Engine.IO settings
    socket = await _tryConnectionStrategy('Polling with EIO3', {
      'transports': ['polling'],
      'upgrade': false,
      'autoConnect': false,
      'timeout': 10000,
      'forceNew': true,
      'forceBase64': true,
    }, token);
    
    if (socket != null) return socket;

    // Strategy 3: Try WebSocket only
    socket = await _tryConnectionStrategy('WebSocket Only', {
      'transports': ['websocket'],
      'autoConnect': false,
      'timeout': 10000,
      'forceNew': true,
    }, token);
    
    if (socket != null) return socket;

    // Strategy 4: Try with custom path
    socket = await _tryConnectionStrategy('Custom Path', {
      'transports': ['polling'],
      'upgrade': false,
      'autoConnect': false,
      'timeout': 10000,
      'forceNew': true,
      'path': '/socket.io/',
    }, token);
    
    if (socket != null) return socket;

    _log('ERROR: All connection strategies failed');
    return null;
  }

  Future<io.Socket?> _tryConnectionStrategy(
    String strategyName, 
    Map<String, dynamic> options, 
    String token
  ) async {
    _log('Trying strategy: $strategyName');
    
    final url = ServerConstants.baseUrl;
    io.Socket? socket;
    
    try {
      socket = io.io(url, options);
      
      final completer = Completer<io.Socket?>();
      Timer? timeoutTimer;
      bool authSuccess = false;
      
      socket.on('connect', (_) {
        _log('$strategyName: Connected, attempting authentication...');
        socket!.emit('auth', token);
      });
      
      socket.on('auth_success', (_) {
        _log('$strategyName: Authentication successful!');
        authSuccess = true;
        if (!completer.isCompleted) {
          completer.complete(socket);
        }
      });
      
      socket.on('auth_error', (data) {
        _log('$strategyName: Authentication failed: $data');
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });
      
      socket.on('connect_error', (error) {
        _log('$strategyName: Connection error: $error');
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });
      
      socket.on('error', (error) {
        _log('$strategyName: Socket error: $error');
      });
      
      // Set timeout for this strategy
      timeoutTimer = Timer(const Duration(seconds: 15), () {
        _log('$strategyName: Timeout reached');
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });
      
      socket.connect();
      
      final result = await completer.future;
      timeoutTimer?.cancel();
      
      if (result != null && authSuccess) {
        _log('$strategyName: Strategy successful!');
        return result;
      } else {
        _log('$strategyName: Strategy failed');
        socket.disconnect();
        socket.dispose();
        return null;
      }
      
    } catch (e) {
      _log('$strategyName: Exception: $e');
      socket?.disconnect();
      socket?.dispose();
      return null;
    }
  }

  // Test if the server is reachable at all
  Future<bool> testServerReachability() async {
    _log('Testing server reachability...');
    
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      
      final uri = Uri.parse(ServerConstants.baseUrl);
      final request = await client.getUrl(uri);
      final response = await request.close();
      
      _log('Server responded with status: ${response.statusCode}');
      client.close();
      
      // Any response (even 404) means server is reachable
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      _log('Server unreachable: $e');
      return false;
    }
  }

  // Test specific socket.io endpoints
  Future<Map<String, bool>> testSocketIOEndpoints() async {
    _log('Testing Socket.IO endpoints...');
    
    final results = <String, bool>{};
    final baseUrl = ServerConstants.baseUrl;
    
    // Test different possible socket.io paths
    final testPaths = [
      '/socket.io/?EIO=4&transport=polling',
      '/socket.io/?EIO=3&transport=polling',
      '/socket.io/socket.io.js',
      '/',
    ];
    
    for (final path in testPaths) {
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 5);
        
        final uri = Uri.parse('$baseUrl$path');
        final request = await client.getUrl(uri);
        final response = await request.close();
        
        final success = response.statusCode == 200;
        results[path] = success;
        _log('Endpoint $path: ${success ? 'SUCCESS' : 'FAILED'} (${response.statusCode})');
        
        client.close();
      } catch (e) {
        results[path] = false;
        _log('Endpoint $path: ERROR - $e');
      }
    }
    
    return results;
  }

  // Comprehensive diagnostic
  Future<Map<String, dynamic>> runDiagnostic() async {
    _log('Running comprehensive diagnostic...');
    
    final results = <String, dynamic>{};
    
    // Test 1: Server reachability
    results['server_reachable'] = await testServerReachability();
    
    // Test 2: Socket.IO endpoints
    results['socketio_endpoints'] = await testSocketIOEndpoints();
    
    // Test 3: Token check
    final token = await _authRepo.getAccessToken();
    results['has_token'] = token != null;
    if (token != null) {
      results['token_length'] = token.length;
    }
    
    // Test 4: URL parsing
    try {
      final uri = Uri.parse(ServerConstants.baseUrl);
      results['url_valid'] = true;
      results['server_host'] = uri.host;
      results['server_port'] = uri.port;
      results['server_scheme'] = uri.scheme;
    } catch (e) {
      results['url_valid'] = false;
      results['url_error'] = e.toString();
    }
    
    _log('Diagnostic completed');
    return results;
  }
}