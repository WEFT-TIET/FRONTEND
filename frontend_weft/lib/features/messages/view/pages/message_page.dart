// pages/message_page.dart
import 'package:flutter/material.dart';
import 'package:frontend_weft/features/messages/models/chat.dart';
import 'package:frontend_weft/features/messages/widgets/chat_tile.dart';
import 'chat_detail_page.dart';


class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  List<Chat> _filteredChats = [];
  bool _isSearching = false;

  // Dummy data - replace with actual socket data
  final List<Chat> _chats = [
    Chat(
      id: '1',
      name: 'Alice Johnson',
      username: '@alice',
      profilePic: 'https://randomuser.me/api/portraits/women/1.jpg',
      lastMessage: 'Hey! How are you doing today?',
      lastMessageTime: DateTime.now().subtract(Duration(minutes: 5)),
      unreadCount: 2,
      
    ),
    Chat(
      id: '2',
      name: 'Bob Smith',
      username: '@bob',
      profilePic: 'https://randomuser.me/api/portraits/men/2.jpg',
      lastMessage: 'Let\'s catch up later this evening.',
      lastMessageTime: DateTime.now().subtract(Duration(minutes: 45)),
      unreadCount: 0,
      
      lastSeen: DateTime.now().subtract(Duration(hours: 2)),
    ),
    Chat(
      id: '3',
      name: 'Charlie Lee',
      username: '@charlie',
      profilePic: 'https://randomuser.me/api/portraits/men/3.jpg',
      lastMessage: 'I\'ve sent you the files you requested.',
      lastMessageTime: DateTime.now().subtract(Duration(days: 1)),
      unreadCount: 1,
      
      lastSeen: DateTime.now().subtract(Duration(hours: 12)),
    ),
    Chat(
      id: '4',
      name: 'Diana Prince',
      username: '@diana',
      profilePic: 'https://randomuser.me/api/portraits/women/4.jpg',
      lastMessage: 'Thanks for the help with the project!',
      lastMessageTime: DateTime.now().subtract(Duration(days: 2)),
      unreadCount: 0,
      
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _filteredChats = _chats;
    _animationController.forward();
    
    _searchController.addListener(_filterChats);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterChats() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredChats = _chats;
        _isSearching = false;
      } else {
        _isSearching = true;
        _filteredChats = _chats
            .where((chat) =>
                chat.name.toLowerCase().contains(query) ||
                chat.username.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _navigateToChat(Chat chat) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChatDetailPage(
          chat: chat,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
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
        body: SafeArea(
          child: Column(
            children: [
              // Header with title and search
              _buildHeader(),
              
              // Search bar
              _buildSearchBar(),
              
              // Chat list
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _filteredChats.isEmpty
                      ? _buildEmptyState()
                      : _buildChatList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            'Messages',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.white, size: 24),
              onPressed: () {
                // Handle new chat
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFF3A3E7A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.6),
            size: 24,
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white.withOpacity(0.6),
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _filteredChats.length,
      itemBuilder: (context, index) {
        final chat = _filteredChats[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          child: ChatTile(
            chat: chat,
            onTap: () => _navigateToChat(chat),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              _isSearching ? Icons.search_off : Icons.message,
              size: 60,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 24),
          Text(
            _isSearching ? 'No conversations found' : 'No messages yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 12),
          Text(
            _isSearching
                ? 'Try searching with different keywords'
                : 'Start a conversation to see it here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}