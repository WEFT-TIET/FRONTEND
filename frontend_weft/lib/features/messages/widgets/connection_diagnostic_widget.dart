import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_local_repository.dart';

class ConnectionDiagnosticWidget extends ConsumerStatefulWidget {
  const ConnectionDiagnosticWidget({super.key});

  @override
  ConsumerState<ConnectionDiagnosticWidget> createState() => _ConnectionDiagnosticWidgetState();
}

class _ConnectionDiagnosticWidgetState extends ConsumerState<ConnectionDiagnosticWidget> {
  List<String> _logs = [];
  bool _isRunning = false;

  void _log(String message) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: $message');
    });
    print('🔍 $message');
  }

  Future<void> _runDiagnostic() async {
    setState(() {
      _isRunning = true;
      _logs.clear();
    });

    _log('Starting comprehensive diagnostic...');

    // Test 1: Basic HTTP connectivity
    await _testHttpConnectivity();

    // Test 2: Socket.IO endpoint
    await _testSocketIOEndpoint();

    // Test 3: Authentication token
    await _testAuthToken();

    // Test 4: Different socket.io paths
    await _testDifferentPaths();

    setState(() {
      _isRunning = false;
    });

    _log('Diagnostic completed!');
  }

  Future<void> _testHttpConnectivity() async {
    _log('Testing basic HTTP connectivity...');
    
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      
      final uri = Uri.parse(ServerConstants.baseUrl);
      _log('Testing URL: ${uri.toString()}');
      
      final request = await client.getUrl(uri);
      final response = await request.close();
      
      _log('HTTP Response: ${response.statusCode}');
      _log('HTTP Headers: ${response.headers.toString()}');
      
      if (response.statusCode == 200) {
        final body = await response.transform(const Utf8Decoder()).join();
        _log('Response body preview: ${body.substring(0, body.length > 200 ? 200 : body.length)}...');
      }
      
      client.close();
      
      if (response.statusCode >= 200 && response.statusCode < 500) {
        _log('✅ HTTP connectivity: SUCCESS');
      } else {
        _log('❌ HTTP connectivity: FAILED (${response.statusCode})');
      }
    } catch (e) {
      _log('❌ HTTP connectivity: ERROR - $e');
    }
  }

  Future<void> _testSocketIOEndpoint() async {
    _log('Testing Socket.IO endpoint...');
    
    final testUrls = [
      '${ServerConstants.baseUrl}/socket.io/?EIO=4&transport=polling',
      '${ServerConstants.baseUrl}/socket.io/?EIO=3&transport=polling',
      '${ServerConstants.baseUrl}/socket.io/socket.io.js',
    ];

    for (final testUrl in testUrls) {
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 5);
        
        final uri = Uri.parse(testUrl);
        _log('Testing Socket.IO URL: $testUrl');
        
        final request = await client.getUrl(uri);
        request.headers.set('Accept', '*/*');
        request.headers.set('User-Agent', 'Flutter-SocketIO-Client');
        
        final response = await request.close();
        
        _log('Socket.IO Response: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final body = await response.transform(const Utf8Decoder()).join();
          _log('Socket.IO body preview: ${body.substring(0, body.length > 100 ? 100 : body.length)}...');
          _log('✅ Socket.IO endpoint: SUCCESS');
          break;
        } else {
          _log('❌ Socket.IO endpoint: FAILED (${response.statusCode})');
        }
        
        client.close();
      } catch (e) {
        _log('❌ Socket.IO endpoint: ERROR - $e');
      }
    }
  }

  Future<void> _testAuthToken() async {
    _log('Testing authentication token...');
    
    try {
      final authRepo = ref.read(authLocalRepositoryProvider);
      final token = await authRepo.getAccessToken();
      
      if (token != null) {
        _log('✅ Auth token: AVAILABLE (length: ${token.length})');
        _log('Token preview: ${token.substring(0, token.length > 50 ? 50 : token.length)}...');
      } else {
        _log('❌ Auth token: NOT AVAILABLE');
      }
    } catch (e) {
      _log('❌ Auth token: ERROR - $e');
    }
  }

  Future<void> _testDifferentPaths() async {
    _log('Testing different server paths...');
    
    final testPaths = [
      '/',
      '/health',
      '/api',
      '/socket.io/',
    ];

    for (final path in testPaths) {
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 5);
        
        final url = '${ServerConstants.baseUrl}$path';
        final uri = Uri.parse(url);
        
        final request = await client.getUrl(uri);
        final response = await request.close();
        
        _log('Path $path: ${response.statusCode}');
        
        client.close();
      } catch (e) {
        _log('Path $path: ERROR - $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Diagnostic'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Server info
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Server Information',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('Base URL: ${ServerConstants.baseUrl}'),
                    Text('Expected Socket.IO: ${ServerConstants.baseUrl}/socket.io/'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Run diagnostic button
            ElevatedButton(
              onPressed: _isRunning ? null : _runDiagnostic,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isRunning
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Running Diagnostic...'),
                      ],
                    )
                  : const Text('Run Diagnostic'),
            ),

            const SizedBox(height: 16),

            // Logs
            const Text(
              'Diagnostic Logs:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _logs.isEmpty
                    ? const Center(
                        child: Text(
                          'No logs yet. Run diagnostic to see results.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          final isError = log.contains('❌') || log.contains('ERROR');
                          final isSuccess = log.contains('✅') || log.contains('SUCCESS');
                          
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isError ? Colors.red.withOpacity(0.1) : 
                                     isSuccess ? Colors.green.withOpacity(0.1) : null,
                            ),
                            child: Text(
                              log,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: isError ? Colors.red : 
                                       isSuccess ? Colors.green : null,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Clear logs button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _logs.clear();
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Clear Logs'),
            ),
          ],
        ),
      ),
    );
  }
}