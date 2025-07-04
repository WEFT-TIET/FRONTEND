import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class PostCard extends StatelessWidget {
  final String name;
  final String tag;
  final String timeAgo;
  final String content;
  final int stars;
  final int comments;

  const PostCard({
    super.key,
    required this.name,
    required this.tag,
    required this.timeAgo,
    required this.content,
    this.stars = 0,
    this.comments = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPallete.glassWhite05, // Dark background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Name + Time
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: AppPallete.whiteColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                  ),
                  Text(
                    '$tag • $timeAgo',
                    style: const TextStyle(color: AppPallete.whiteColor, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Post content
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Footer: stars + comments
          Row(
            children: [
              const Icon(Icons.star, size: 18, color: Colors.amber),
              const SizedBox(width: 4),
              Text('$stars', style: const TextStyle(color: Colors.white70)),

              const SizedBox(width: 16),

              const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white38),
              const SizedBox(width: 4),
              Text('$comments', style: const TextStyle(color: Colors.white70)),
            ],
          )
        ],
      ),
    );
  }
}
