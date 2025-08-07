import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend_weft/features/messages/models/message_model.dart';
import 'package:frontend_weft/features/messages/service/socket_service.dart';

final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, List<ChatMessage>, int>((ref, receiverId) {
  final socket = ref.read(socketServiceProvider);
  final notifier = ChatMessagesNotifier(ref, socket, receiverId);
  return notifier;
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier(this.ref, this._socket, this.receiverId) : super([]) {
    _init();
  }

  final Ref ref;
  final SocketService _socket;
  final int receiverId;

  Future<void> _init() async {
    await _socket.connect();
    _socket.messagesStream.listen((msg) {
      // Only add messages relevant to this conversation
      final authUser = ref.read(authViewModelProvider);
      if (authUser != null) {
        final currentUserId = int.parse(authUser.id);
        if ((msg.senderId == currentUserId && msg.receiverId == receiverId) ||
            (msg.senderId == receiverId && msg.receiverId == currentUserId)) {
          state = [...state, msg];
        }
      }
    });
  }

  void sendMessage(String content) {
    final authUser = ref.read(authViewModelProvider);
    if (authUser == null) return;
    _socket.sendMessage(receiverId: receiverId, content: content, senderId: int.parse(authUser.id));
  }
}

class ChatPage extends ConsumerStatefulWidget {
  final int receiverId;
  const ChatPage({super.key, required this.receiverId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('💬 Chat page opened for receiverId: ${widget.receiverId}');
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider(widget.receiverId));
    final socket = ref.read(socketServiceProvider);
    print('📝 Chat messages count: ${messages.length}');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chat'),
            Text(
              socket.isConnected ? 'Online' : 'Connecting...',
              style: TextStyle(
                fontSize: 12,
                color: socket.isConnected ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.senderId != widget.receiverId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(msg.content, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    ref.read(chatMessagesProvider(widget.receiverId).notifier).sendMessage(text);
                    _controller.clear();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
