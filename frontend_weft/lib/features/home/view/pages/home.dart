import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/home/view/Drawer/drawer.dart';
import 'package:frontend_weft/features/home/view/widgets/event_card.dart';
import 'package:frontend_weft/features/post/view/widgets/post_card.dart';
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
                SizedBox(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 15,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) => PostCard(
                      name: 'Rudra',
                      tag: 'CCS',
                      timeAgo: '2h ago',
                      content:
                          'Join us for the CCS Tech Fest! Exciting events and workshops await.',
                      stars: 21,
                      comments: 5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
