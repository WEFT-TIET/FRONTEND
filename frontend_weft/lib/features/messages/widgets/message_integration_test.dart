import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/messages/view/pages/chat_page.dart';
import 'package:frontend_weft/features/messages/view/pages/messages_list_page.dart';
import 'package:frontend_weft/features/messages/widgets/socket_test_widget.dart';
import 'package:frontend_weft/features/messages/widgets/socket_debug_widget.dart';
import 'package:frontend_weft/features/messages/widgets/connection_diagnostic_widget.dart';
import 'package:frontend_weft/features/messages/viewmodel/chat_viewmodel.dart';
import 'package:frontend_weft/features/messages/viewmodel/conversations_viewmodel.dart';

/// Test widget to verify message integration from profile pages
class MessageIntegrationTest extends ConsumerWidget {
  const MessageIntegrationTest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Integration Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Message Integration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Connection Status
            Consumer(
              builder: (context, ref, child) {
                final connectionState = ref.watch(socketConnectionProvider);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Socket Connection Status:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        connectionState.when(
                          data: (isConnected) => Row(
                            children: [
                              Icon(
                                isConnected ? Icons.check_circle : Icons.error,
                                color: isConnected ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(isConnected ? 'Connected' : 'Disconnected'),
                            ],
                          ),
                          loading: () => const Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Connecting...'),
                            ],
                          ),
                          error: (error, _) => Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Error: $error')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Test Buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MessagesListPage(),
                  ),
                );
              },
              child: const Text('Open Messages List'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatPage(
                      receiverId: 2, // Test user ID
                      receiverName: 'Test User',
                    ),
                  ),
                );
              },
              child: const Text('Open Test Chat (User ID: 2)'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SocketTestWidget(),
                  ),
                );
              },
              child: const Text('Open Socket Test Widget'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SocketDebugWidget(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Open Socket Debug Widget'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConnectionDiagnosticWidget(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Run Connection Diagnostic'),
            ),
            
            const SizedBox(height: 20),
            
            // Conversations Status
            Consumer(
              builder: (context, ref, child) {
                final conversationsState = ref.watch(conversationsProvider);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Conversations:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (conversationsState.isLoading)
                          const Text('Loading conversations...')
                        else if (conversationsState.error != null)
                          Text(
                            'Error: ${conversationsState.error}',
                            style: const TextStyle(color: Colors.red),
                          )
                        else
                          Text('${conversationsState.conversations.length} conversations'),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const Spacer(),
            
            // Instructions
            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Integration Test Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Check that socket connection shows "Connected"\n'
                      '2. Test opening messages list\n'
                      '3. Test opening a chat with a specific user\n'
                      '4. Verify messages can be sent and received\n'
                      '5. Check that conversations are properly managed',
                      style: TextStyle(color: Colors.white),
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
}