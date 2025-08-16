import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/core/http_client.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/features/post/model/post_model.dart';
import 'package:frontend_weft/features/post/model/comment_model.dart';
import 'package:frontend_weft/features/post/view/widgets/post_card.dart';
import 'package:frontend_weft/features/post/view/widgets/comment_card.dart';
import 'package:frontend_weft/features/post/view/pages/comment_page.dart';
import 'package:frontend_weft/features/post/viewmodel/post_viewmodel.dart';
import 'dart:convert';

enum ActivityTab { liked, commented }

// Activity data model - directly in this file
class ActivityRecord {
  final String? type;
  final int? postId;
  final String? postTitle;
  final int? commentId;
  final String? commentContent;
  final DateTime createdAt;

  ActivityRecord({
    this.type,
    this.postId,
    this.postTitle,
    this.commentId,
    this.commentContent,
    required this.createdAt,
  });

  factory ActivityRecord.fromJson(Map<String, dynamic> json) {
    return ActivityRecord(
      type: json['Type'],
      postId: json['PostID'],
      postTitle: json['PostTitle'],
      commentId: json['CommentID'],
      commentContent: json['CommentContent'],
      createdAt: _parseDateTime(json['CreatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic dateStr) {
    if (dateStr == null) return DateTime.now();
    if (dateStr is String) {
      if (dateStr == '0001-01-01T00:00:00Z') {
        return DateTime.now();
      }
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  bool get isLike => type?.toLowerCase() == 'like';
  bool get isComment => type?.toLowerCase() == 'comment';
}

// Activity state management - directly in this file
class ActivityState {
  final List<ActivityRecord> activities;
  final bool isLoading;
  final String? error;
  final Map<String, Post> postsCache;

  ActivityState({
    this.activities = const [],
    this.isLoading = false,
    this.error,
    this.postsCache = const {},
  });

  List<ActivityRecord> get likedPosts =>
      activities.where((a) => a.isLike).toList();

  List<ActivityRecord> get commentedPosts =>
      activities.where((a) => a.isComment).toList();

  ActivityState copyWith({
    List<ActivityRecord>? activities,
    bool? isLoading,
    String? error,
    Map<String, Post>? postsCache,
  }) {
    return ActivityState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      postsCache: postsCache ?? this.postsCache,
    );
  }
}

// Activity provider - directly in this file
class ActivityNotifier extends StateNotifier<ActivityState> {
  final AppHttpClient _httpClient;

  ActivityNotifier(this._httpClient) : super(ActivityState());

  Future<void> fetchActivity() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch activity data
      final activityUri = Uri.parse('${ServerConstants.baseUrl}/activity');
      final activityResponse = await _httpClient.get(activityUri);

      if (activityResponse.statusCode == 200) {
        final List<dynamic> activityJson = json.decode(activityResponse.body);
        final activities = activityJson
            .map((json) => ActivityRecord.fromJson(json))
            .toList();

        state = state.copyWith(
          activities: activities,
          isLoading: false,
        );

        // Fetch post details for activities in the background
        _enrichPostsInBackground();
      } else {
        state = state.copyWith(
          error: 'Failed to load activity: ${activityResponse.statusCode}',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Network error: $e',
        isLoading: false,
      );
    }
  }

  Future<void> _enrichPostsInBackground() async {
    final postIds = state.activities
        .where((a) => a.postId != null)
        .map((a) => a.postId!)
        .toSet();

    Map<String, Post> newPostsCache = Map.from(state.postsCache);

    for (final postId in postIds) {
      if (!newPostsCache.containsKey(postId.toString())) {
        try {
          final post = await _fetchPostById(postId);
          if (post != null) {
            newPostsCache[postId.toString()] = post;
          }
        } catch (e) {
          // Ignore individual post fetch errors
        }
      }
    }

    if (newPostsCache.length != state.postsCache.length) {
      state = state.copyWith(postsCache: newPostsCache);
    }
  }

  Future<Post?> _fetchPostById(int postId) async {
    try {
      final uri = Uri.parse('${ServerConstants.baseUrl}/posts/$postId');
      final response = await _httpClient.get(uri);

      if (response.statusCode == 200) {
        final postJson = json.decode(response.body);
        return Post.fromJson(postJson);
      }
    } catch (e) {
      // Return null on error
    }
    return null;
  }

  Post? getPostForActivity(ActivityRecord activity) {
    if (activity.postId != null) {
      return state.postsCache[activity.postId.toString()];
    }
    return null;
  }

  void updatePostLikeStatus(String postId, bool liked) {
    final activities = state.activities.where((a) {
      return a.postId?.toString() != postId || a.isLike != true;
    }).toList();

    state = state.copyWith(activities: activities);
  }

  Future<void> refresh() async {
    await fetchActivity();
  }
}

final activityProvider = StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return ActivityNotifier(httpClient);
});

class YourActivityPage extends ConsumerStatefulWidget {
  const YourActivityPage({super.key});

  @override
  ConsumerState<YourActivityPage> createState() => _YourActivityPageState();
}

class _YourActivityPageState extends ConsumerState<YourActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ActivityTab selectedTab = ActivityTab.liked;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedTab = _tabController.index == 0 ? ActivityTab.liked : ActivityTab.commented;
      });
    });
    
    // Load data from backend when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activityProvider.notifier).fetchActivity();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Convert ActivityRecord to Post for liked posts
  Post _activityToPost(ActivityRecord activity) {
    // Try to get the enriched post data first
    final enrichedPost = ref.read(activityProvider.notifier).getPostForActivity(activity);
    if (enrichedPost != null) {
      return enrichedPost;
    }
    
    // Fallback to basic data from activity record
    return Post(
      id: activity.postId?.toString() ?? '0',
      userId: '0', // Not available in activity record
      username: 'Loading...', // Will be updated when post details are fetched
      title: activity.postTitle ?? 'Untitled Post',
      content: 'Loading post content...', // Will be updated when post details are fetched
      createdAt: activity.createdAt.toIso8601String(),
      likesCount: 1, // Assume at least 1 like since user liked it
      commentsCount: 0, // Will be updated when post details are fetched
      liked: true,
      verified: false,
    );
  }

  // Convert ActivityRecord to Comment for commented posts
  Comment _activityToComment(ActivityRecord activity) {
    return Comment(
      id: activity.commentId?.toString() ?? '0',
      userId: '0', // User's own comment
      userName: 'You',
      content: activity.commentContent ?? 'Comment content not available',
      createdAt: activity.createdAt.toIso8601String(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activityState = ref.watch(activityProvider);
    
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
                onPressed: () => ref.read(activityProvider.notifier).refresh(),
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
        body: activityState.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppPallete.textPrimaryDark),
                ),
              )
            : activityState.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppPallete.textPrimaryDark.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load activity',
                          style: TextStyle(
                            color: AppPallete.textPrimaryDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activityState.error!,
                          style: TextStyle(
                            color: AppPallete.whiteColor,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.read(activityProvider.notifier).refresh(),
                          child: Text('Retry'),
                        ),
                      ],
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
    final activityState = ref.watch(activityProvider);
    final likedActivities = activityState.likedPosts;
    
    if (likedActivities.isEmpty) {
      return _buildEmptyState(
        icon: Icons.star_border,
        title: 'No Liked Wefts',
        subtitle: 'Posts you like will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(activityProvider.notifier).refresh(),
      color: AppPallete.profileAccent,
      backgroundColor: AppPallete.glassWhite20,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: likedActivities.length,
        itemBuilder: (context, index) {
          final activity = likedActivities[index];
          final post = _activityToPost(activity);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _ActivityPostCard(
              post: post,
              activity: activity,
              onLikeChanged: (postId, liked) {
                ref.read(activityProvider.notifier).updatePostLikeStatus(postId, liked);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentedWeftsTab() {
    final activityState = ref.watch(activityProvider);
    final commentedActivities = activityState.commentedPosts;
    
    if (commentedActivities.isEmpty) {
      return _buildEmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'No Comments',
        subtitle: 'Posts you\'ve commented on will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(activityProvider.notifier).refresh(),
      color: AppPallete.profileAccent,
      backgroundColor: AppPallete.glassWhite20,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: commentedActivities.length,
        itemBuilder: (context, index) {
          final activity = commentedActivities[index];
          final comment = _activityToComment(activity);
          return GestureDetector(
            onTap: () async {
              // Navigate to the comment section of the post
              if (activity.postId != null) {
                // Try to get the post from cache or create a basic post object
                final post = ref.read(activityProvider.notifier).getPostForActivity(activity) ?? 
                  Post(
                    id: activity.postId.toString(),
                    userId: '0',
                    username: 'Author',
                    title: activity.postTitle ?? 'Post',
                    content: '',
                    createdAt: DateTime.now().toIso8601String(),
                    likesCount: 0,
                    commentsCount: 0,
                    liked: false,
                  );
                
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommentPage(post: post),
                  ),
                );
              }
            },
            child: Container(
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
                        Expanded(
                          child: Text(
                            'Your Comment on: ${activity.postTitle ?? 'Post'}',
                            style: TextStyle(
                              color: AppPallete.textPrimaryDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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

// Custom wrapper for PostCard that listens to like changes
class _ActivityPostCard extends ConsumerStatefulWidget {
  final Post post;
  final ActivityRecord activity;
  final Function(String postId, bool liked) onLikeChanged;

  const _ActivityPostCard({
    required this.post,
    required this.activity,
    required this.onLikeChanged,
  });

  @override
  ConsumerState<_ActivityPostCard> createState() => _ActivityPostCardState();
}

class _ActivityPostCardState extends ConsumerState<_ActivityPostCard> {
  late Post _currentPost;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
  }

  @override
  Widget build(BuildContext context) {
    // Listen to post viewmodel changes
    final postState = ref.watch(postViewModelProvider);
    
    // Check if our post has been updated in the global post state
    final updatedPost = postState.posts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => _currentPost,
    );
    
    // If the post's liked status changed, notify the parent
    if (updatedPost.liked != _currentPost.liked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onLikeChanged(updatedPost.id, updatedPost.liked);
      });
    }
    
    _currentPost = updatedPost;

    return PostCard(
      postId: _currentPost.id,
      userId: _currentPost.userId,
      username: _currentPost.username,
      tag: _currentPost.title,
      timeAgo: _formatTimeAgo(_currentPost.createdAt),
      content: _currentPost.content,
      stars: _currentPost.likesCount,
      comments: _currentPost.commentsCount,
      liked: _currentPost.liked,
      verified: _currentPost.verified,
      showActions: true,
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