// lib/features/home/widgets/posts_list_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/post/view/widgets/post_card.dart';
import 'package:frontend_weft/features/post/viewmodel/post_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

class PostsListWidget extends ConsumerWidget {
  final String searchQuery;
  final String selectedFilter;

  const PostsListWidget({
    super.key,
    required this.searchQuery,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);

    return postsAsync.when(
      data: (posts) {
        // Filter posts based on search query and selected filter
        var filteredPosts = searchQuery.isEmpty
            ? posts
            : posts.where((post) => post.title
                .toLowerCase()
                .contains(searchQuery)).toList();

        // Apply filter
        switch (selectedFilter) {
          case 'Recent':
            filteredPosts.sort((a, b) => 
              DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));
            break;
          case 'Popular':
            filteredPosts.sort((a, b) => b.likesCount.compareTo(a.likesCount));
            break;
        }

        if (filteredPosts.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(postViewModelProvider.notifier)
                .refreshPosts();
          },
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              final post = filteredPosts[index];
              return PostCard(
                postId: post.id,
                name: post.userName,
                tag: post.title,
                timeAgo: _formatTimeAgo(post.createdAt),
                content: post.content,
              );
            },
          ),
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error, ref),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPallete.whiteColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              searchQuery.isEmpty ? Icons.post_add : Icons.search_off,
              size: 64,
              color: AppPallete.textPrimaryDark.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty ? 'No posts yet' : 'No matching posts found',
            style: GoogleFonts.getFont(
              'Oswald',
              color: AppPallete.textPrimaryDark.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Be the first to share something!'
                : 'Try a different search term',
            style: GoogleFonts.getFont(
              'Indie Flower',
              color: AppPallete.textPrimaryDark.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPallete.gradient1.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppPallete.gradient2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading posts...',
            style: GoogleFonts.getFont(
              'Indie Flower',
              color: AppPallete.textPrimaryDark.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(error, WidgetRef ref) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPallete.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: AppPallete.red.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: GoogleFonts.getFont(
              'Oswald',
              color: AppPallete.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Don\'t worry, we\'ll fix this!',
            style: GoogleFonts.getFont(
              'Indie Flower',
              color: AppPallete.textPrimaryDark.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(postViewModelProvider.notifier).refreshPosts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.gradient2,
              foregroundColor: AppPallete.whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: Text(
              'Try Again',
              style: GoogleFonts.getFont(
                'Oswald',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final difference = DateTime.now().difference(dateTime);

      if (difference.inMinutes < 1) return 'just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      return '${difference.inDays}d ago';
    } catch (e) {
      return 'unknown';
    }
  }
}