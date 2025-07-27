// pages/chat_detail_page.dart
import 'package:flutter/material.dart';
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
  final ScrollController _scrollController = ScrollController();
  final String _currentUserId = 'current_user_id'; // Replace with actual user ID
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isTyping = false;

  // Dummy messages - replace with socket data
  final List<Message> _messages = [
    Message(
      id: '1',
      senderId: 'other_user_id',
      receiverId: 'current_user_id',
      content: 'Hey! How are you doing today?',
      timestamp: DateTime.now().subtract(Duration(minutes: 30)),
      status: MessageStatus.read,
    ),
    Message(
      id: '2',
      senderId: 'current_user_id',
      receiverId: 'other_user_id',
      content: 'I\'m doing great! Thanks for asking. How about you?',
      timestamp: DateTime.now().subtract(Duration(minutes: 25)),
      status: MessageStatus.delivered,
    ),
    Message(
      id: '3',
      senderId: 'other_user_id',
      receiverId: 'current_user_id',
      content: 'I\'m good too! Working on some interesting projects lately.',
      timestamp: DateTime.now().subtract(Duration(minutes: 20)),
      status: MessageStatus.read,
    ),
    Message(
      id: '4',
      senderId: 'current_user_id',
      receiverId: 'other_user_id',
      content: 'That sounds exciting! Would love to hear more about them.',
      timestamp: DateTime.now().subtract(Duration(minutes: 15)),
      status: MessageStatus.sent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;

    setState(() {
      _isTyping = true;
    });

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId,
      receiverId: widget.chat.id,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    setState(() {
      _messages.add(newMessage);
    });

    // Simulate sending message via socket
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isTyping = false;
        // Update message status
        final index = _messages.indexWhere((m) => m.id == newMessage.id);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            status: MessageStatus.sent,
          );
        }
      });
      _scrollToBottom();
    });

    _scrollToBottom();
  }

  void _handleUserAction(UserAction action) {
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
        _showDeleteChatDialog();
        break;
      case UserAction.muteChat:
        _showMuteDialog();
        break;
      case UserAction.unmuteChat:
        // Handle unmute
        break;
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF3A3E7A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: Text(
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
            SizedBox(height: 16),
            Text(
              widget.chat.name,
              style: TextStyle(
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
            child: Text(
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
        backgroundColor: Color(0xFF3A3E7A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: Text(
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
              // Handle block user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.chat.name} has been blocked'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(
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
        backgroundColor: Color(0xFF3A3E7A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: Text(
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
            SizedBox(height: 16),
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
        style: TextStyle(color: Colors.white),
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
        backgroundColor: Color(0xFF3A3E7A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: Text(
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
              Navigator.pop(context); // Go back to message list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chat deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(
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
        backgroundColor: Color(0xFF3A3E7A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: Text(
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
                SnackBar(
                  content: Text('Chat muted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: Text(
              'Mute',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
            // Messages list
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isMe = message.senderId == _currentUserId;
                    
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      curve: Curves.easeOutBack,
                      child: MessageBubble(
                        message: message,
                        isMe: isMe,
                        currentUserId: _currentUserId,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Typing indicator
            if (_isTyping)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Sending...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Message input
            MessageInput(
              onSendMessage: _sendMessage,
              isTyping: _isTyping,
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
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.chat.profilePic),
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                   widget.chat.lastSeen != null
                          ? 'Last seen ${_formatLastSeen(widget.chat.lastSeen!)}'
                          : widget.chat.username,
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
        SizedBox(width: 8),
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