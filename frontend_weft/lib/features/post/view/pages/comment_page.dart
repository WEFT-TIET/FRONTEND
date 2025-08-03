import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentState = ref.watch(commentViewModelProvider(post.id));

    return Scaffold(
      backgroundColor: AppPallete.profileBackgroundDark,
      appBar: AppBar(
        backgroundColor: AppPallete.profileBackgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppPallete.textPrimaryDark,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Comments',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppPallete.textPrimaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Post content at the top
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Post card
                  PostCard(
                    postId: post.id,
                    userId: post.userId,
                    username: post.username,
                    tag: 'User',
                    timeAgo: _formatTimeAgo(post.createdAt),
                    content: post.content,
                    stars: post.likesCount,
                    comments: post.commentsCount,
                    liked: post.liked,
                    showMenu: false, // Hide menu in comment page
                  ),
                  
                  const Divider(
                    color: AppPallete.glassWhite20,
                    height: 1,
                  ),
                  
                  // Comments section
                  if (commentState.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppPallete.gradient2),
                        ),
                      ),
                    )
                  else if (commentState.error != null)
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppPallete.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load comments',
                              style: TextStyle(
                                color: AppPallete.textPrimaryDark,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              commentState.error!,
                              style: const TextStyle(
                                color: AppPallete.whiteColor,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(commentViewModelProvider(post.id).notifier).refreshComments();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppPallete.gradient2,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (commentState.comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: AppPallete.whiteColor,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: TextStyle(
                                color: AppPallete.textPrimaryDark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to comment!',
                              style: const TextStyle(
                                color: AppPallete.whiteColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // Comments list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: commentState.comments.length,
                      itemBuilder: (context, index) {
                        return CommentCard(
                          comment: commentState.comments[index],
                        );
                      },
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