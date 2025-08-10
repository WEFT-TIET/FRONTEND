import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/messages/service/socket_service.dart';
import 'package:frontend_weft/features/messages/viewmodel/chat_viewmodel.dart';

class SocketTestWidget extends ConsumerStatefulWidget {
  const SocketTestWidget({super.key});

  @override
  ConsumerState<SocketTestWidget> createState() => _SocketTestWidgetState();
}

class _SocketTestWidgetState extends ConsumerState<SocketTestWidget> {
  String _status = 'Disconnected';
  List<String> _logs = [];
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _testConnection();
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();
    _messageSubscription?.cancel();
    super.dispose();
  }

  void _setupListeners() {
    final socket = ref.read(socketServiceProvider);
    
    _connectionSubscription = socket.authStatusStream.listen((isConnected) {
      setState(() {
        _status = isConnected ? 'Connected & Authenticated' : 'Disconnected';
        _logs.add('${DateTime.now().toIso8601String()}: Auth status changed: $isConnected');
      });
    });

    _errorSubscription = socket.errorStream.listen((error) {
      setState(() {
        _logs.add('${DateTime.now().toIso8601String()}: ERROR: $error');
      });
    });

    _messageSubscription = socket.messagesStream.listen((message) {
      setState(() {
        _logs.add('${DateTime.now().toIso8601String()}: MESSAGE: ${message.content} from ${message.senderId}');
      });
    });
  }

  Future<void> _testConnection() async {
    final socket = ref.read(socketServiceProvider);
    
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: Starting connection test...');
    });

    try {
      await socket.connect();
      setState(() {
        _logs.add('${DateTime.now().toIso8601String()}: Connection initiated');
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _logs.add('${DateTime.now().toIso8601String()}: Connection error: $e');
      });
    }
  }

  void _sendTestMessage() {
    final socket = ref.read(socketServiceProvider);
    if (!socket.isConnected) {
      setState(() {
        _logs.add('${DateTime.now().toIso8601String()}: Cannot send - not connected');
      });
      return;
    }

    socket.sendMessage(
      receiverId: 2, // Test receiver ID
      content: 'Test message from socket test widget',
      senderId: 1, // Test sender ID
    );
    
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: Test message sent');
    });
  }

  void _fetchTestMessages() {
    final socket = ref.read(socketServiceProvider);
    if (!socket.isConnected) {
      setState(() {
        _logs.add('${DateTime.now().toIso8601String()}: Cannot fetch - not connected');
      });
      return;
    }

    socket.fetchMessages(1);
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: Fetching messages page 1');
    });
  }

  void _testBasicConnection() async {
    final socket = ref.read(socketServiceProvider);
    
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: Starting basic connection test...');
    });

    try {
      await socket.testConnection();
      setState(() {
        _logs.add('${DateTime.now().toIso8601String()}: Basic test initiated');
      });
    } catch (e) {
      setState(() {
        _logs.add('${DateTime.now().toIso8601String()}: Basic test error: $e');
      });
    }
  }

  void _forceReconnect() async {
    final socket = ref.read(socketServiceProvider);
    
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: Force reconnecting...');
    });

    try {
      await socket.forceReconnect();
      setState(() {
        _logs.add('${DateTime.now().toIso8601String()}: Force reconnect initiated');
      });
    } catch (e) {
      setState(() {
        _logs.add('${DateTime.now().toIso8601String()}: Force reconnect error: $e');
      });
    }
  }

  void _disconnect() {
    final socket = ref.read(socketServiceProvider);
    socket.disconnect();
    
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: Manual disconnect');
    });
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(socketConnectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearLogs,
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $_status',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    connectionState.when(
                      data: (isConnected) => Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isConnected ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(isConnected ? 'Online' : 'Offline'),
                        ],
                      ),
                      loading: () => const Text('Checking connection...'),
                      error: (error, _) => Text('Error: $error', style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _testConnection,
                  child: const Text('Connect'),
                ),
                ElevatedButton(
                  onPressed: _testBasicConnection,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Test Basic'),
                ),
                ElevatedButton(
                  onPressed: _forceReconnect,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: const Text('Force Reconnect'),
                ),
                ElevatedButton(
                  onPressed: _sendTestMessage,
                  child: const Text('Send Test Message'),
                ),
                ElevatedButton(
                  onPressed: _fetchTestMessages,
                  child: const Text('Fetch Messages'),
                ),
                ElevatedButton(
                  onPressed: _disconnect,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Disconnect'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Logs section
            const Text('Logs:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _logs.isEmpty
                    ? const Center(child: Text('No logs yet'))
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          final isError = log.contains('ERROR');
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isError ? Colors.red.withValues(alpha: 0.1) : null,
                            ),
                            child: Text(
                              log,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: isError ? Colors.red : null,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
