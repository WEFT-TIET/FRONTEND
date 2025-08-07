import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/messages/service/socket_service.dart';

class SocketTestWidget extends ConsumerStatefulWidget {
  const SocketTestWidget({super.key});

  @override
  ConsumerState<SocketTestWidget> createState() => _SocketTestWidgetState();
}

class _SocketTestWidgetState extends ConsumerState<SocketTestWidget> {
  String _status = 'Disconnected';
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    final socket = ref.read(socketServiceProvider);
    
    setState(() {
      _logs.add('Starting connection test...');
    });

    try {
      await socket.connect();
      setState(() {
        _status = socket.isConnected ? 'Connected' : 'Failed to connect';
        _logs.add('Connection status: $_status');
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _logs.add('Connection error: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Socket Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $_status', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Logs:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(_logs[index], style: const TextStyle(fontFamily: 'monospace')),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _testConnection,
              child: const Text('Test Connection'),
            ),
          ],
        ),
      ),
    );
  }
}
