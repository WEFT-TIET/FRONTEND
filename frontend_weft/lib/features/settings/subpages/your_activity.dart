import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/post/model/post_model.dart';
import 'package:frontend_weft/features/post/model/comment_model.dart';
import 'package:frontend_weft/features/post/view/widgets/post_card.dart';
import 'package:frontend_weft/features/post/view/widgets/comment_card.dart';

enum ActivityTab { liked, commented }

class YourActivityPage extends ConsumerStatefulWidget {
  const YourActivityPage({super.key});

  @override
  ConsumerState<YourActivityPage> createState() => _YourActivityPageState();
}

class _YourActivityPageState extends ConsumerState<YourActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ActivityTab selectedTab = ActivityTab.liked;

  // Mock data - replace with actual data from your service
  List<Post> likedPosts = [];
  List<Comment> commentedPosts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedTab = _tabController.index == 0 ? ActivityTab.liked : ActivityTab.commented;
      });
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    // Mock data - replace with actual API calls
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock liked posts
    likedPosts = [
      Post(
        id: '1',
        userId: 'user1',
        username: 'JohnDoe',
        title: 'Tech Discussion',
        content: 'Just discovered this amazing new Flutter package that makes animations so much smoother! 🚀',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        likesCount: 15,
        commentsCount: 8,
        liked: true,
        verified: true,
      ),
      Post(
        id: '2',
        userId: 'user2',
        username: 'SarahTech',
        title: 'Study Tips',
        content: 'Best productivity tips for college students: 1. Use Pomodoro technique 2. Take regular breaks 3. Stay hydrated',
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        likesCount: 23,
        commentsCount: 12,
        liked: true,
      ),
    ];

    // Mock commented posts
    commentedPosts = [
      Comment(
        id: 'c1',
        userId: 'currentUser',
        userName: 'You',
        content: 'Great point! I completely agree with your perspective on this topic.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      ),
      Comment(
        id: 'c2',
        userId: 'currentUser',
        userName: 'You',
        content: 'Thanks for sharing this! Really helpful information.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      ),
    ];

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPallete.gradient1,
            AppPallete.gradient2,
            AppPallete.gradient3,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppPallete.glassWhite10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppPallete.glassWhite20, width: 0.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: const Text(
            'Your Activity',
            style: TextStyle(
              color: AppPallete.textPrimaryDark,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppPallete.glassWhite10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppPallete.glassWhite20, width: 0.5),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: AppPallete.textPrimaryDark, size: 20),
                onPressed: _loadData,
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppPallete.glassWhite10,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppPallete.glassWhite20, width: 0.5),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    colors: [AppPallete.gradient2, AppPallete.profileAccent],
                  ),
                ),
                labelColor: AppPallete.whiteColor,
                unselectedLabelColor: AppPallete.textPrimaryDark.withOpacity(0.7),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, size: 18),
                        const SizedBox(width: 8),
                        Text('Liked Wefts'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble, size: 18),
                        const SizedBox(width: 8),
                        Text('Commented'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppPallete.textPrimaryDark),
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildLikedWeftsTab(),
                  _buildCommentedWeftsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildLikedWeftsTab() {
    if (likedPosts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.star_border,
        title: 'No Liked Wefts',
        subtitle: 'Posts you like will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppPallete.profileAccent,
      backgroundColor: AppPallete.glassWhite20,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: likedPosts.length,
        itemBuilder: (context, index) {
          final post = likedPosts[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: PostCard(
              postId: post.id,
              userId: post.userId,
              username: post.username,
              tag: post.title,
              timeAgo: _formatTimeAgo(post.createdAt),
              content: post.content,
              stars: post.likesCount,
              comments: post.commentsCount,
              liked: post.liked,
              verified: post.verified,
              showActions: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentedWeftsTab() {
    if (commentedPosts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'No Comments',
        subtitle: 'Posts you\'ve commented on will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppPallete.profileAccent,
      backgroundColor: AppPallete.glassWhite20,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: commentedPosts.length,
        itemBuilder: (context, index) {
          final comment = commentedPosts[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppPallete.glassWhite05,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPallete.glassWhite20, width: 0.5),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppPallete.glassWhite10,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble,
                        color: AppPallete.profileAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Comment',
                        style: TextStyle(
                          color: AppPallete.textPrimaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimeAgo(comment.createdAt),
                        style: TextStyle(
                          color: AppPallete.whiteColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CommentCard(comment: comment),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppPallete.glassWhite10,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppPallete.glassWhite20, width: 0.5),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppPallete.textPrimaryDark.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                color: AppPallete.textPrimaryDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: AppPallete.whiteColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(String createdAt) {
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}