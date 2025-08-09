import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/messages/service/socket_debug_service.dart';
import 'package:frontend_weft/core/server_constants.dart';

class SocketDebugWidget extends ConsumerStatefulWidget {
  const SocketDebugWidget({super.key});

  @override
  ConsumerState<SocketDebugWidget> createState() => _SocketDebugWidgetState();
}

class _SocketDebugWidgetState extends ConsumerState<SocketDebugWidget> {
  bool _isRunningDiagnostic = false;
  Map<String, dynamic>? _diagnosticResults;

  @override
  Widget build(BuildContext context) {
    final debugService = ref.read(socketDebugServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket Debug'),
        backgroundColor: Colors.red,
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
                      'Server Configuration',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('Base URL: ${ServerConstants.baseUrl}'),
                    Text('Socket.IO URL: ${ServerConstants.baseUrl}/socket.io/'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Diagnostic results
            if (_diagnosticResults != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Diagnostic Results',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ..._diagnosticResults!.entries.map((entry) {
                        final isSuccess = entry.value == true;
                        final isFailure = entry.value == false;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                isSuccess ? Icons.check_circle : 
                                isFailure ? Icons.error : Icons.info,
                                color: isSuccess ? Colors.green : 
                                       isFailure ? Colors.red : Colors.blue,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${entry.key}: ${entry.value}',
                                  style: TextStyle(
                                    color: isFailure ? Colors.red : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
                  onPressed: _isRunningDiagnostic ? null : _runComprehensiveDiagnostic,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: _isRunningDiagnostic 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Run Diagnostic'),
                ),
                ElevatedButton(
                  onPressed: _testHttpConnectivity,
                  child: const Text('Test HTTP'),
                ),
                ElevatedButton(
                  onPressed: _testSocketIOEndpoint,
                  child: const Text('Test Socket.IO'),
                ),
                ElevatedButton(
                  onPressed: _testConfigurations,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Test Configs'),
                ),
                ElevatedButton(
                  onPressed: () {
                    debugService.clearLogs();
                    setState(() {
                      _diagnosticResults = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Clear'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Debug logs
            const Text(
              'Debug Logs:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final debugService = ref.read(socketDebugServiceProvider);
                    final logs = debugService.debugLogs;
                    
                    if (logs.isEmpty) {
                      return const Center(child: Text('No debug logs yet'));
                    }
                    
                    return ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        final isError = log.contains('failed') || log.contains('error') || log.contains('Error');
                        final isSuccess = log.contains('successful') || log.contains('Connected') || log.contains('Authentication successful');
                        
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
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            const Card(
              color: Colors.amber,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debug Instructions:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '1. Run Diagnostic first to check overall connectivity\n'
                      '2. Test HTTP to verify server is reachable\n'
                      '3. Test Socket.IO to check if socket endpoint works\n'
                      '4. Test Configs to try different connection methods\n'
                      '5. Check logs for detailed error information',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runComprehensiveDiagnostic() async {
    setState(() {
      _isRunningDiagnostic = true;
      _diagnosticResults = null;
    });

    try {
      final debugService = ref.read(socketDebugServiceProvider);
      final results = await debugService.runComprehensiveDiagnostic();
      
      setState(() {
        _diagnosticResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Diagnostic failed: $e')),
      );
    } finally {
      setState(() {
        _isRunningDiagnostic = false;
      });
    }
  }

  Future<void> _testHttpConnectivity() async {
    final debugService = ref.read(socketDebugServiceProvider);
    final result = await debugService.testHttpConnectivity();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('HTTP Test: ${result ? 'SUCCESS' : 'FAILED'}'),
        backgroundColor: result ? Colors.green : Colors.red,
      ),
    );
    
    setState(() {}); // Refresh logs
  }

  Future<void> _testSocketIOEndpoint() async {
    final debugService = ref.read(socketDebugServiceProvider);
    final result = await debugService.testSocketIOEndpoint();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Socket.IO Test: ${result ? 'SUCCESS' : 'FAILED'}'),
        backgroundColor: result ? Colors.green : Colors.red,
      ),
    );
    
    setState(() {}); // Refresh logs
  }

  Future<void> _testConfigurations() async {
    final debugService = ref.read(socketDebugServiceProvider);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Testing different configurations...')),
    );
    
    await debugService.testDifferentConfigurations();
    
    setState(() {}); // Refresh logs
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration tests completed')),
    );
  }
}