import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_local_repository.dart';

final socketDebugServiceProvider = Provider<SocketDebugService>((ref) {
  final repo = ref.read(authLocalRepositoryProvider);
  return SocketDebugService(repo);
});

class SocketDebugService {
  SocketDebugService(this._authRepo);

  final AuthLocalRepository _authRepo;
  final List<String> _debugLogs = [];

  List<String> get debugLogs => List.unmodifiable(_debugLogs);

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '$timestamp: $message';
    _debugLogs.add(logMessage);
    print('🐛 $logMessage');
  }

  void clearLogs() {
    _debugLogs.clear();
  }

  // Test basic HTTP connectivity to the server
  Future<bool> testHttpConnectivity() async {
    _log('Testing HTTP connectivity to ${ServerConstants.baseUrl}');
    
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      
      final uri = Uri.parse(ServerConstants.baseUrl);
      final request = await client.getUrl(uri);
      final response = await request.close();
      
      _log('HTTP response status: ${response.statusCode}');
      _log('HTTP response headers: ${response.headers}');
      
      client.close();
      return response.statusCode == 200 || response.statusCode == 404; // 404 is OK, means server is responding
    } catch (e) {
      _log('HTTP connectivity test failed: $e');
      return false;
    }
  }

  // Test socket.io endpoint specifically
  Future<bool> testSocketIOEndpoint() async {
    _log('Testing Socket.IO endpoint');
    
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      
      // Test the socket.io polling endpoint
      final uri = Uri.parse('${ServerConstants.baseUrl}/socket.io/?EIO=4&transport=polling');
      _log('Testing URL: $uri');
      
      final request = await client.getUrl(uri);
      request.headers.set('Accept', '*/*');
      request.headers.set('User-Agent', 'Flutter-SocketIO-Client');
      
      final response = await request.close();
      
      _log('Socket.IO endpoint status: ${response.statusCode}');
      _log('Socket.IO response headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(const Utf8Decoder()).join();
        _log('Socket.IO response body: ${responseBody.substring(0, responseBody.length > 200 ? 200 : responseBody.length)}...');
      }
      
      client.close();
      return response.statusCode == 200;
    } catch (e) {
      _log('Socket.IO endpoint test failed: $e');
      return false;
    }
  }

  // Test different socket.io configurations
  Future<void> testDifferentConfigurations() async {
    final token = await _authRepo.getAccessToken();
    if (token == null) {
      _log('No access token available for testing');
      return;
    }

    final url = ServerConstants.baseUrl;
    _log('Testing different socket configurations for: $url');

    // Configuration 1: Polling only, no upgrade
    await _testConfiguration('Config 1: Polling only', {
      'transports': ['polling'],
      'upgrade': false,
      'autoConnect': false,
      'timeout': 10000,
    }, token);

    // Configuration 2: WebSocket only
    await _testConfiguration('Config 2: WebSocket only', {
      'transports': ['websocket'],
      'autoConnect': false,
      'timeout': 10000,
    }, token);

    // Configuration 3: Both transports, allow upgrade
    await _testConfiguration('Config 3: Both transports', {
      'transports': ['polling', 'websocket'],
      'upgrade': true,
      'autoConnect': false,
      'timeout': 10000,
    }, token);

    // Configuration 4: With custom path
    await _testConfiguration('Config 4: Custom path', {
      'transports': ['polling'],
      'upgrade': false,
      'autoConnect': false,
      'timeout': 10000,
      'path': '/socket.io/',
    }, token);
  }

  Future<void> _testConfiguration(String configName, Map<String, dynamic> options, String token) async {
    _log('Testing $configName');
    
    final url = ServerConstants.baseUrl;
    io.Socket? testSocket;
    
    try {
      testSocket = io.io(url, options);
      
      final completer = Completer<void>();
      Timer? timeoutTimer;
      
      testSocket.on('connect', (_) {
        _log('$configName: Connected successfully');
        testSocket!.emit('auth', token);
      });
      
      testSocket.on('auth_success', (_) {
        _log('$configName: Authentication successful');
        if (!completer.isCompleted) completer.complete();
      });
      
      testSocket.on('auth_error', (data) {
        _log('$configName: Authentication failed: $data');
        if (!completer.isCompleted) completer.completeError('Auth failed: $data');
      });
      
      testSocket.on('connect_error', (error) {
        _log('$configName: Connection error: $error');
        if (!completer.isCompleted) completer.completeError('Connection error: $error');
      });
      
      testSocket.on('error', (error) {
        _log('$configName: General error: $error');
      });
      
      // Set timeout
      timeoutTimer = Timer(const Duration(seconds: 15), () {
        if (!completer.isCompleted) {
          completer.completeError('Timeout');
        }
      });
      
      testSocket.connect();
      
      try {
        await completer.future;
        _log('$configName: Test completed successfully');
      } catch (e) {
        _log('$configName: Test failed: $e');
      }
      
      timeoutTimer?.cancel();
      testSocket.disconnect();
      
    } catch (e) {
      _log('$configName: Setup error: $e');
    } finally {
      testSocket?.dispose();
    }
    
    // Wait between tests
    await Future.delayed(const Duration(seconds: 2));
  }

  // Comprehensive diagnostic
  Future<Map<String, dynamic>> runComprehensiveDiagnostic() async {
    _log('Starting comprehensive diagnostic...');
    
    final results = <String, dynamic>{};
    
    // Test 1: HTTP connectivity
    results['http_connectivity'] = await testHttpConnectivity();
    
    // Test 2: Socket.IO endpoint
    results['socketio_endpoint'] = await testSocketIOEndpoint();
    
    // Test 3: Token availability
    final token = await _authRepo.getAccessToken();
    results['token_available'] = token != null;
    if (token != null) {
      results['token_length'] = token.length;
      results['token_preview'] = token.substring(0, token.length > 20 ? 20 : token.length);
    }
    
    // Test 4: Network info
    try {
      final uri = Uri.parse(ServerConstants.baseUrl);
      results['server_host'] = uri.host;
      results['server_port'] = uri.port;
      results['server_scheme'] = uri.scheme;
    } catch (e) {
      results['url_parse_error'] = e.toString();
    }
    
    _log('Diagnostic completed: $results');
    return results;
  }
}

