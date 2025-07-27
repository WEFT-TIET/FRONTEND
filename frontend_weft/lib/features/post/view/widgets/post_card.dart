import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/post/viewmodel/post_viewmodel.dart';

class PostCard extends ConsumerWidget {
  final String postId;
  final String userId;
  final String name;
  final String tag;
  final String timeAgo;
  final String content;
  final int stars;
  final int comments;
  final bool showMenu;

  const PostCard({
    super.key,
    this.postId = '',
    required this.userId,
    required this.name,
    required this.tag,
    required this.timeAgo,
    required this.content,
    this.stars = 0,
    this.comments = 0,
    this.showMenu = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPallete.glassWhite05, // Original dark background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPallete.glassWhite20, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
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
              if (showMenu)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppPallete.textPrimaryDark,
                  ),
                  color: AppPallete.glassWhite20,
                  onSelected: (value) {
                    switch (value) {
                      case 'report':
                        _showReportDialog(context, ref);
                        break;
                      case 'block':
                        _showBlockDialog(context, ref);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(
                            Icons.report_outlined,
                            color: AppPallete.textPrimaryDark,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Report Post',
                            style: TextStyle(
                              color: AppPallete.textPrimaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'block',
                      child: Row(
                        children: [
                          Icon(
                            Icons.block_outlined,
                            color: AppPallete.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Block User',
                            style: TextStyle(
                              color: AppPallete.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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

  void _showReportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppPallete.glassWhite20,
          title: Text(
            'Report Post',
            style: TextStyle(color: AppPallete.textPrimaryDark),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why are you reporting this post?',
                style: TextStyle(color: AppPallete.textPrimaryDark),
              ),
              const SizedBox(height: 16),
              _buildReportOption('Spam or misleading'),
              _buildReportOption('Harassment or hate speech'),
              _buildReportOption('Inappropriate content'),
              _buildReportOption('Violence or dangerous content'),
              _buildReportOption('Other'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppPallete.textPrimaryDark),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportOption(String reason) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () {
          Navigator.of(context).pop();
          _submitReport(context, reason);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            reason,
            style: TextStyle(color: AppPallete.textPrimaryDark),
          ),
        ),
      ),
    );
  }

  void _showBlockDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppPallete.glassWhite20,
          title: Text(
            'Block User',
            style: TextStyle(color: AppPallete.textPrimaryDark),
          ),
          content: Text(
            'Are you sure you want to block $name? You won\'t see their posts anymore.',
            style: TextStyle(color: AppPallete.textPrimaryDark),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppPallete.textPrimaryDark),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _blockUser(context, userId, ref);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppPallete.red,
              ),
              child: const Text('Block'),
            ),
          ],
        );
      },
    );
  }

  void _submitReport(BuildContext context, String reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post reported for: $reason'),
        backgroundColor: AppPallete.gradient2,
      ),
    );
  }

  void _blockUser(BuildContext context, String userId, WidgetRef ref) {
    ref.read(postViewModelProvider.notifier).blockUser(userId).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name has been blocked'),
            backgroundColor: AppPallete.gradient2,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to block user'),
            backgroundColor: AppPallete.red,
          ),
        );
      }
    });
  }
}