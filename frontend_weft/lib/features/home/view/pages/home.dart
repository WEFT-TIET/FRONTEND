import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/home/view/Drawer/drawer.dart';
import 'package:frontend_weft/features/home/view/widgets/event_card.dart';
import 'package:frontend_weft/features/post/view/widgets/post_card.dart';
import 'package:frontend_weft/features/post/viewmodel/post_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
      child: Scaffold(
        backgroundColor: AppPallete.transperantColor,
        appBar: AppBar(
          backgroundColor: AppPallete.transperantColor,
          elevation: 0,
          title: Text(
            'Hi Rudra !',
            style: GoogleFonts.getFont(
              'Indie Flower',
              fontSize: 30,
              color: AppPallete.textPrimaryDark,
            ),
          ),
          iconTheme: IconThemeData(color: AppPallete.textPrimaryDark),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(postViewModelProvider.notifier).refreshPosts();
              },
            ),
            IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          ],
        ),
        drawer: DrawerWidget(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Simple dialog to create a post for testing
            _showCreatePostDialog(context, ref);
          },
          backgroundColor: AppPallete.gradient2,
          child: const Icon(Icons.add, color: AppPallete.whiteColor),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'SOCIETY EVENTS',
                  style: GoogleFonts.getFont(
                    'Oswald',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppPallete.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) => EventCard(
                      title: 'CCS',
                      subtitle: 'CCS Tech Fest',
                      date: 'Dec 15',
                      location: 'Main Auditorium',

                      backgroundColor: AppPallete.eventCardColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "STUDENTS' POSTS",
                  style: GoogleFonts.getFont(
                    'Oswald',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppPallete.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 15),
                Consumer(
                  builder: (context, ref, _) {
                    final postsAsync = ref.watch(postsProvider);

                    return postsAsync.when(
                      data: (posts) {
                        if (posts.isEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 40),
                                Icon(
                                  Icons.cloud_off_outlined,
                                  size: 64,
                                  color: AppPallete.textPrimaryDark.withOpacity(
                                    0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No posts available',
                                  style: TextStyle(
                                    color: AppPallete.textPrimaryDark
                                        .withOpacity(0.7),
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Check your connection or try refreshing',
                                  style: TextStyle(
                                    color: AppPallete.textPrimaryDark
                                        .withOpacity(0.5),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ref
                                        .read(postViewModelProvider.notifier)
                                        .refreshPosts();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppPallete.gradient2,
                                    foregroundColor: AppPallete.whiteColor,
                                  ),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Refresh'),
                                ),
                              ],
                            ),
                          );
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
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              return PostCard(
                                postId: post.id,
                                name: post.userName,
                                tag: post.title,
                                timeAgo: _formatTimeAgo(post.createdAt),
                                content: post.content,
                                stars: post.likesCount,
                                comments: post.commentsCount,
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppPallete.red.withOpacity(0.7),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load posts',
                              style: TextStyle(
                                color: AppPallete.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              style: TextStyle(
                                color: AppPallete.textPrimaryDark.withOpacity(
                                  0.7,
                                ),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(postViewModelProvider.notifier)
                                    .refreshPosts();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppPallete.gradient2,
                                foregroundColor: AppPallete.whiteColor,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
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

  void _showCreatePostDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPallete.scaffoldBackgroundColorDark,
        title: Text(
          'Create Post',
          style: TextStyle(color: AppPallete.textPrimaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(color: AppPallete.textPrimaryDark),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(
                  color: AppPallete.textPrimaryDark.withOpacity(0.7),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppPallete.gradient2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppPallete.gradient1),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              style: TextStyle(color: AppPallete.textPrimaryDark),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Content',
                labelStyle: TextStyle(
                  color: AppPallete.textPrimaryDark.withOpacity(0.7),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppPallete.gradient2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppPallete.gradient1),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppPallete.textPrimaryDark.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty &&
                  contentController.text.trim().isNotEmpty) {
                final success = await ref
                    .read(postViewModelProvider.notifier)
                    .createPost(
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                    );

                Navigator.pop(context);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to create post'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.gradient2,
              foregroundColor: AppPallete.whiteColor,
            ),
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}
