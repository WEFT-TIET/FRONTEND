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
            IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          ],
        ),
        drawer: DrawerWidget(),
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
                      data: (posts) => ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return PostCard(
                            name: post.userName,
                            tag: post.title,
                            timeAgo: _formatTimeAgo(post.createdAt),
                            content: post.content,
                            stars: post.likesCount,
                            comments: post.commentsCount,
                          );
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          Center(child: Text('Error: $error')),
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
    final dateTime = DateTime.parse(dateTimeStr);
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
