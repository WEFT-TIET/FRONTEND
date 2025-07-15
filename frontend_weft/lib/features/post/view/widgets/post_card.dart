import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/post/viewmodel/post_viewmodel.dart';

class PostCard extends ConsumerWidget {
  final String postId;
  final String name;
  final String tag;
  final String timeAgo;
  final String content;
  final int stars;
  final int comments;

  const PostCard({
    super.key,
    this.postId = '',
    required this.name,
    required this.tag,
    required this.timeAgo,
    required this.content,
    this.stars = 0,
    this.comments = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPallete.glassWhite05, // Dark background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPallete.glassWhite20, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppPallete.gradient2,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: AppPallete.whiteColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppPallete.textPrimaryDark,
                      ),
                    ),
                    Text(
                      '$tag • $timeAgo',
                      style: const TextStyle(
                        color: AppPallete.whiteColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Post content
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppPallete.textPrimaryDark,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Footer: likes + comments
          Row(
            children: [
              GestureDetector(
                onTap: postId.isNotEmpty
                    ? () {
                        ref
                            .read(postViewModelProvider.notifier)
                            .likePost(postId);
                      }
                    : null,
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: stars > 0 ? Colors.red : Colors.white38,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$stars',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Row(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 18,
                    color: Colors.white38,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$comments',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
