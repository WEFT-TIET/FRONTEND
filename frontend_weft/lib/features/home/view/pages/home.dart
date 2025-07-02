import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/home/view/Drawer/attendance.dart';
import 'package:frontend_weft/features/home/view/Drawer/event.dart';
import 'package:frontend_weft/features/home/view/Drawer/map.dart';
import 'package:frontend_weft/features/home/view/Drawer/party.dart';
import 'package:frontend_weft/features/home/view/widgets/event_card.dart';
import 'package:frontend_weft/features/post/view/widgets/post_card.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppPallete.gradient1, AppPallete.gradient2, AppPallete.gradient3],
        ),
      ),
      child: Scaffold(
        backgroundColor: AppPallete.transperantColor,
        appBar: AppBar(
          backgroundColor: AppPallete.transperantColor,
          elevation: 0,
          title: Text(
            'Hi, Rudra !',
            style: GoogleFonts.getFont(
              'Indie Flower', 
              fontSize: 30,
              color: AppPallete.textPrimaryDark,
            ),
          ),
          iconTheme: IconThemeData(color: AppPallete.textPrimaryDark),
          actions: [
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: AppPallete.textPrimaryDark,
              ),
              onPressed: () {},
            ),
          ],
        ),
        drawer: SafeArea(
          child: SizedBox(
            width: 280,
            child: Drawer(
              backgroundColor: AppPallete.profileBackgroundDark,
              child: Column(
                children: <Widget>[
                  // Header
                  Container(
                    height: 100,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppPallete.gradient1,
                          AppPallete.gradient2,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'For Students',
                        style: TextStyle(
                          color: AppPallete.textPrimaryDark,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // Menu Items
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      children: <Widget>[
                        _buildMenuItem(
                          context: context,
                          icon: Icons.event,
                          title: 'Society Events',
                          page: EventPage(),
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.calendar_month_rounded,
                          title: 'Attendance',
                          page: AttendancePage(),
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.map,
                          title: 'Map',
                          page: ThaparMapScreen(),
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.mic,
                          title: 'Party Tickets',
                          page: PartyPage(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                  height: 200,
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
                const SizedBox(height: 30),
                Text(
                  'STUDENTS\' POSTS',
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

  // Helper method for drawer menu items
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppPallete.glassWhite05,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppPallete.glassWhite10,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppPallete.profileAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppPallete.profileAccent,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppPallete.textPrimaryDark,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppPallete.profileTextSecondary,
          size: 16,
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}