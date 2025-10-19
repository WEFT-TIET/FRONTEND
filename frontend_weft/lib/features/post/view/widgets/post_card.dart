import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/post/viewmodel/post_viewmodel.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend_weft/features/post/model/post_model.dart';
import 'package:frontend_weft/features/post/view/pages/comment_page.dart';

class PostCard extends ConsumerStatefulWidget {
  final String postId;
  final String userId;
  final String username;
  final String tag;
  final String timeAgo;
  final String content;
  final int stars;
  final int comments;
  final bool liked;
  final bool showMenu;
  final bool showActions; // New parameter to control like/comment buttons
  final bool verified;
  final String? imageUrl; // Optional image
  final VoidCallback? onPostDeleted; // Callback for post deletion

  const PostCard({
    super.key,
    this.postId = '',
    required this.userId,
    required this.username,
    required this.tag,
    required this.timeAgo,
    required this.content,
    this.stars = 0,
    this.comments = 0,
    this.liked = false,
    this.showMenu = true,
    this.showActions = true, // Default to true to show actions
    this.verified = false,
  this.imageUrl,
    this.onPostDeleted, // Optional callback
  });

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool _isExpanded = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final theme = Theme.of(context);
    final currentUser = ref.watch(authViewModelProvider);
    final isCurrentUserPost = currentUser?.id == widget.userId;

    // Debug logging for verification
    if (widget.verified) {
      print("🎯 PostCard: Rendering verification badge for ${widget.username}");
    } else {
      print("❌ PostCard: No verification badge for ${widget.username} (verified: ${widget.verified})");
    }

    // Additional validation to fix backend inconsistency
    // If likes count is 0, the post should not be marked as liked
    final actuallyLiked = widget.stars > 0 ? widget.liked : false;

    // Check if post content is longer than 50 words
    final words = widget.content.trim().split(RegExp(r'\s+'));
    final shouldShowReadMore = words.length > 50;
    final displayContent = shouldShowReadMore && !_isExpanded 
        ? '${words.take(50).join(' ')}...'
        : widget.content;

    return GestureDetector(
      onTap: () {
        // Navigate to comment page when post is tapped
        if (widget.postId.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CommentPage(
                post: Post(
                  id: widget.postId,
                  userId: widget.userId,
                  username: widget.username,
                  title: widget.tag, // Use the actual tag/title
                  content: widget.content,
                  createdAt: DateTime.now()
                      .toIso8601String(), // This will be overridden by actual data
                  likesCount: widget.stars,
                  commentsCount: widget.comments,
                  liked: widget.liked,
                  verified: widget.verified,
                ),
              ),
            ),
          );
        }
      },
      child: Container(
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
                    widget.username.isNotEmpty ? widget.username[0].toUpperCase() : 'U',
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
                        widget.tag,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppPallete.textPrimaryDark,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            widget.username,
                            style: const TextStyle(
                              color: AppPallete.whiteColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (widget.verified) ...[
                            const SizedBox(width: 6), // Increased spacing
                            const Icon(
                              Icons.verified,
                              color: Color(0xFF10B981),
                              size: 16, // Increased from 14 to 16
                            ),
                          ],
                          Text(
                            ' • ${widget.timeAgo}',
                            style: const TextStyle(
                              color: AppPallete.whiteColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.showMenu)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: AppPallete.textPrimaryDark,
                    ),
                    color: AppPallete.profileDialogBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppPallete.gradient1.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'delete':
                          _showDeleteDialog(context, ref);
                          break;
                        case 'report':
                          _showReportDialog(context, ref);
                          break;
                        case 'block':
                          _showBlockDialog(context, ref);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      // Show delete option only for current user's posts
                      if (isCurrentUserPost)
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppPallete.red.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: AppPallete.red,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Delete Post',
                                  style: TextStyle(
                                    color: AppPallete.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Show report and block options only for other users' posts
                      if (!isCurrentUserPost) ...[
                        PopupMenuItem<String>(
                          value: 'report',
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.report_outlined,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Report Post',
                                  style: TextStyle(
                                    color: AppPallete.textPrimaryDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'block',
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppPallete.red.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.block_outlined,
                                    color: AppPallete.red,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Block User',
                                  style: TextStyle(
                                    color: AppPallete.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Post content with read more functionality
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((widget.imageUrl ?? '').isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16/9,
                      child: Image.network(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image, color: Colors.white54),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.black12,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppPallete.gradient2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  displayContent,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16, // Increased from default bodyMedium size
                    fontWeight: FontWeight.w500,
                    color: AppPallete.textPrimaryDark,
                    height: 1.6, // Slightly increased line height for better readability
                    letterSpacing: 0.2, // Added letter spacing for better readability
                  ),
                ),
                if (shouldShowReadMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(
                        _isExpanded ? 'Show less' : 'Read more',
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Footer: likes + comments (only show if showActions is true)
            if (widget.showActions)
              Row(
                children: [
                GestureDetector(
                  onTap: widget.postId.isNotEmpty
                      ? () {
                          ref
                              .read(postViewModelProvider.notifier)
                              .likePost(widget.postId);
                        }
                      : null,
                  child: Row(
                    children: [
                      Icon(
                        actuallyLiked ? Icons.star : Icons.star_border,
                        size: 24,
                        color: actuallyLiked 
                            ? AppPallete.secondaryDark 
                            : Colors.white60,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.stars}',
                        style: TextStyle(
                          color: actuallyLiked 
                              ? AppPallete.secondaryDark 
                              : Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                GestureDetector(
                  onTap: () {
                    // Navigate to comment page when comment icon is tapped
                    if (widget.postId.isNotEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentPage(
                            post: Post(
                              id: widget.postId,
                              userId: widget.userId,
                              username: widget.username,
                              title: widget.tag, // Use the actual tag/title
                              content: widget.content,
                              createdAt: DateTime.now()
                                  .toIso8601String(), // This will be overridden by actual data
                              likesCount: widget.stars,
                              commentsCount: widget.comments,
                              liked: widget.liked,
                              verified: widget.verified,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 24, // Increased from 18
                        color: Colors.white60,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.comments}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppPallete.profileDialogBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppPallete.red.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppPallete.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppPallete.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Delete Post',
                style: TextStyle(
                  color: AppPallete.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPallete.gradient3.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppPallete.gradient1.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppPallete.red.withValues(alpha: 0.8),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Delete this post?',
                        style: TextStyle(
                          color: AppPallete.textPrimaryDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Post preview
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppPallete.cardColorDark.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppPallete.textPrimaryDark.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tag,
                        style: TextStyle(
                          color: AppPallete.textPrimaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.content,
                        style: TextStyle(
                          color: AppPallete.textPrimaryDark.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                Text(
                  'This action cannot be undone. The post will be permanently removed from WEFT.',
                  style: TextStyle(
                    color: AppPallete.textPrimaryDark.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppPallete.textPrimaryDark.withValues(alpha: 0.7),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isDeleting ? null : () {
                Navigator.of(context).pop();
                _deletePost(context, widget.postId, ref);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isDeleting ? AppPallete.red.withValues(alpha: 0.6) : AppPallete.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isDeleting) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Deleting...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    const Icon(Icons.delete, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _deletePost(BuildContext context, String postId, WidgetRef ref) async {
    if (_isDeleting) return; // Prevent multiple simultaneous deletions

    setState(() {
      _isDeleting = true;
    });

    // Show loading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Deleting post...'),
          ],
        ),
        backgroundColor: AppPallete.gradient1,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 30), // Long duration, will be dismissed manually
      ),
    );

    try {
      final result = await ref.read(postViewModelProvider.notifier).deletePost(postId);
      
      if (mounted) {
        // Dismiss loading snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        setState(() {
          _isDeleting = false;
        });

        if (result['success'] == true) {
          // Call the callback if provided (for profile page refresh)
          widget.onPostDeleted?.call();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(result['message'] ?? 'Post deleted successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(result['message'] ?? 'Failed to delete post'),
                  ),
                ],
              ),
              backgroundColor: AppPallete.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Dismiss loading snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        setState(() {
          _isDeleting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text('An unexpected error occurred'),
              ],
            ),
            backgroundColor: AppPallete.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showReportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppPallete.profileDialogBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppPallete.gradient1.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.report_outlined,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Report Post',
                style: TextStyle(
                  color: AppPallete.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why are you reporting this post?',
                style: TextStyle(
                  color: AppPallete.textPrimaryDark.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              _buildReportOption('Spam or misleading', Icons.report_problem),
              _buildReportOption('Harassment or hate speech', Icons.person_off),
              _buildReportOption('Inappropriate content', Icons.warning),
              _buildReportOption('Violence or dangerous content', Icons.dangerous),
              _buildReportOption('Other', Icons.more_horiz),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppPallete.textPrimaryDark.withValues(alpha: 0.7),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportOption(String reason, IconData iconData) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () {
          Navigator.of(context).pop();
          _submitReport(context, reason);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: AppPallete.gradient3.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppPallete.gradient1.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                iconData,
                color: Colors.orange,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reason,
                  style: TextStyle(
                    color: AppPallete.textPrimaryDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppPallete.textPrimaryDark.withValues(alpha: 0.3),
                size: 14,
              ),
            ],
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
          backgroundColor: AppPallete.profileDialogBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppPallete.red.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppPallete.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.block,
                  color: AppPallete.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Block User',
                style: TextStyle(
                  color: AppPallete.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPallete.gradient3.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppPallete.gradient1.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_off,
                  color: AppPallete.red.withValues(alpha: 0.8),
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to block ${widget.username}?',
                  style: TextStyle(
                    color: AppPallete.textPrimaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You won\'t see their posts anymore and they won\'t be able to interact with your content.',
                  style: TextStyle(
                    color: AppPallete.textPrimaryDark.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppPallete.textPrimaryDark.withValues(alpha: 0.7),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _blockUser(context, widget.userId, ref);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.block, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Block',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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
            content: Text('${widget.username} has been blocked'),
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
