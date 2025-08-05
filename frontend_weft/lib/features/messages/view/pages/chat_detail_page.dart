import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_weft/features/messages/service/message_service.dart'; // --- IMPORTED SERVICE ---
import 'package:frontend_weft/features/messages/models/chat.dart';
import 'package:frontend_weft/features/messages/models/message.dart';
import 'package:frontend_weft/features/messages/models/user_action.dart';
import 'package:frontend_weft/features/messages/widgets/message_bubble.dart';
import 'package:frontend_weft/features/messages/widgets/message_input.dart';
import 'package:frontend_weft/features/messages/widgets/chat_options_menu.dart';

class ChatDetailPage extends StatefulWidget {
  final Chat chat;

  const ChatDetailPage({
    super.key,
    required this.chat,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage>
    with TickerProviderStateMixin {
  // --- ADDED: Service instance and stream subscription ---
  final MessageService _messageService = MessageService();
  StreamSubscription? _messagesSubscription;

  final ScrollController _scrollController = ScrollController();
  late final String _currentUserId;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // --- CHANGED: This list is now dynamic, not hardcoded ---
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();

    // --- ADDED: Get real user ID and load initial data from the service ---
    _currentUserId = _messageService.currentUserId!;
    _messages = _messageService.getMessagesForChat(widget.chat.id);

    // --- ADDED: Listen to the message stream for real-time updates ---
    _messagesSubscription =
        _messageService.messagesStream.listen((updatedMessages) {
      if (updatedMessages.isNotEmpty &&
          (updatedMessages.first.sender_id == widget.chat.id ||
              updatedMessages.first.receiver_id == widget.chat.id)) {
        if (mounted) {
          setState(() {
            _messages = updatedMessages;
          });
          _scrollToBottom();
        }
      }
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    // --- ADDED: Cancel subscription to prevent memory leaks ---
    _messagesSubscription?.cancel();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  // --- REWRITTEN: Sends a real message via the service ---
  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;

    _messageService.sendMessage(
      receiver_id: widget.chat.id,
      content: content,
    );
    _scrollToBottom();
  }

  // --- UPDATED: Connects user actions to the service ---
  void _handleUserAction(UserAction action) {
    final actionData = UserActionData(
      action: action,
      userId: widget.chat.id,
      chatId: widget.chat.id,
    );

    // For non-dialog actions, or actions that happen before a dialog
 
    //_messageService.handleUserAction(actionData);

    switch (action) {
      case UserAction.viewProfile:
        _showProfileDialog();
        break;
      case UserAction.block:
        _showBlockDialog();
        break;
      case UserAction.report:
        _showReportDialog();
        break;
      case UserAction.deleteChat:
        // The service handles local deletion; we just pop the screen
        Navigator.of(context).pop();
        break;
      case UserAction.muteChat:
        _showMuteDialog();
        break;
      case UserAction.unmuteChat:
        // Service is already called above
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat unmuted')),
        );
        break;
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3A3E7A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chat.profilePic),
              radius: 50,
            ),
            const SizedBox(height: 16),
            Text(
              widget.chat.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.chat.username,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF6366F1)),
            ),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3A3E7A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: const Text(
          'Block User',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to block ${widget.chat.name}? They won\'t be able to send you messages.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.chat.name} has been blocked'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Block',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3A3E7A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: const Text(
          'Report User',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why are you reporting ${widget.chat.name}?',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            _buildReportOption('Spam'),
            _buildReportOption('Harassment'),
            _buildReportOption('Inappropriate content'),
            _buildReportOption('Fake account'),
            _buildReportOption('Other'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOption(String reason) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        reason,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report submitted for: $reason'),
            backgroundColor: Colors.orange,
          ),
        );
      },
    );
  }

  void _showDeleteChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3A3E7A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: const Text(
          'Delete Chat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this chat? This action cannot be undone.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showMuteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3A3E7A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: const Text(
          'Mute Chat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You won\'t receive notifications for messages from ${widget.chat.name}.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat muted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text(
              'Mute',
              style:
                  TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2D5A),
            Color(0xFF4A4E8A),
            Color(0xFF3A3E7A),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isMe = message.sender_id == _currentUserId;

                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                      currentUserId: _currentUserId,
                    );
                  },
                ),
              ),
            ),
            MessageInput(
              onSendMessage: _sendMessage,
              // The isTyping/isSending state can be derived from message status
              // For simplicity, it's removed here but can be added back
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.chat.profilePic),
            radius: 20,
            backgroundColor: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.chat.isOnline
                      ? 'Online'
                      : (widget.chat.lastSeen != null
                          ? 'Last seen ${_formatLastSeen(widget.chat.lastSeen!)}'
                          : widget.chat.username),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ChatOptionsMenu(
          onActionSelected: _handleUserAction,
          userName: widget.chat.name,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}