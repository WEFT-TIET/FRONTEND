import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/core/widgets/pull_to_refresh_wrapper.dart';
import 'package:frontend_weft/features/post/model/post_model.dart';
import 'package:frontend_weft/features/post/viewmodel/comment_viewmodel.dart';
import 'package:frontend_weft/features/post/view/widgets/comment_card.dart';
import 'package:frontend_weft/features/post/view/widgets/comment_input.dart';
import 'package:frontend_weft/features/post/view/widgets/post_card.dart';

class CommentPage extends ConsumerWidget {
  final Post post;

  const CommentPage({
    super.key,
    required this.post,
  });

  Future<void> _handleRefresh(WidgetRef ref) async {
    // Refresh comments for this specific post
    await ref.read(commentViewModelProvider(post.id).notifier).refreshComments();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentState = ref.watch(commentViewModelProvider(post.id));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.all(6),
                    ),
                    Expanded(
                      child: Text(
                        'Comments',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 36), // To balance the back button
                  ],
                ),
              ),
              
              // Post and comments section
              Expanded(
                child: PullToRefreshAlwaysScrollable(
                  onRefresh: () => _handleRefresh(ref),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Post card without extra container
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: PostCard(
                          postId: post.id,
                          userId: post.userId,
                          username: post.username,
                          tag: post.title, // Use actual post title instead of 'User'
                          timeAgo: _formatTimeAgo(post.createdAt),
                          content: post.content,
                          stars: post.likesCount,
                          comments: post.commentsCount,
                          liked: post.liked,
                          showMenu: false, // Hide menu in comment page
                          showActions: false, // Hide like and comment buttons
                          verified: post.verified,
                          imageUrl: post.imageUrl,
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Comments section
                      if (commentState.isLoading)
                        Container(
                          margin: const EdgeInsets.all(12.0),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppPallete.gradient1.withValues(alpha: 0.7),
                                AppPallete.gradient2.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Loading comments...',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (commentState.error != null)
                        Container(
                          margin: const EdgeInsets.all(12.0),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.withValues(alpha: 0.7),
                                AppPallete.gradient2.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Failed to load comments',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                commentState.error!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  ref.read(commentViewModelProvider(post.id).notifier).refreshComments();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Retry',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (commentState.comments.isEmpty)
                        Container(
                          margin: const EdgeInsets.all(12.0),
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppPallete.gradient1.withValues(alpha: 0.7),
                                AppPallete.gradient2.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No comments yet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Be the first to comment!',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        // Comments list
                        Column(
                          children: commentState.comments.map((comment) {
                            return CommentCard(comment: comment);
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Comment input at the bottom
              CommentInput(
                isLoading: commentState.isCreatingComment,
                onSubmit: (content) {
                  ref.read(commentViewModelProvider(post.id).notifier).createComment(content);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(String createdAt) {
    try {
      final createdTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(createdTime);

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
      return 'Unknown time';
    }
  }
} 