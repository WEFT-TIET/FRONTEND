import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/home/view/Drawer/attendance.dart';
import 'package:frontend_weft/features/home/view/Drawer/event.dart';
import 'package:frontend_weft/features/home/view/Drawer/map.dart';
import 'package:frontend_weft/features/home/view/Drawer/party.dart';
import 'package:frontend_weft/features/home/view/widgets/event_card.dart';
import 'package:frontend_weft/features/post/view/widgets/post_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: const Text('Hi, Rudra'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      drawer: SafeArea(
        child: SizedBox(
          width: 280,
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                SizedBox(
                  height: 80,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    child: Text(
                      'For Students',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text('Society Events'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EventPage()),
                    ); // Close the drawer
                    // Do something
                  },
                ),
                ListTile(
                  leading: Icon(Icons.calendar_month_rounded),
                  title: Text('Attendance'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AttendancePage()),
                    ); // Close the drawer
                    // Navigate to settings
                  },
                ),
                ListTile(
                  leading: Icon(Icons.map),
                  title: Text('Map'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapPage()),
                    ); // Close the drawer
                    // Do something
                  },
                ),
                ListTile(
                  leading: Icon(Icons.mic),
                  title: Text('Party Tickets'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PartyPage()),
                    ); // Close the drawer
                    // Do something
                  },
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
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 35),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (context, index) => const SizedBox(width: 4),
                  itemBuilder: (context, index) => EventCard(
                    title: 'CCS',
                    subtitle: 'CCS Tech Fest',
                    date: 'Dec 15',
                    location: 'Main Auditorium',
                    backgroundColor: const Color.fromARGB(255, 26, 15, 59),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'STUDENTS\' POSTS',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => PostCard(
                    name: 'Rudra',
                    tag: 'CCS',
                    timeAgo: '2h ago',
                    content:
                        'Join us for the CCS Tech Fest! Exciting events and workshops await.',
                    stars: 10,
                    comments: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
