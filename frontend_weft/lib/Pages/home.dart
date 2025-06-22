import 'package:flutter/material.dart';
import 'package:frontend_weft/Drawer/attendance.dart';
import 'package:frontend_weft/Drawer/event.dart';
import 'package:frontend_weft/Drawer/map.dart';
import 'package:frontend_weft/Drawer/party.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(174, 8, 150, 244),
        title: const Text('WEFT'),
        actions: [IconButton(icon: const Icon(Icons.notifications), onPressed: () {
         
        })],
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text('Society Events'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EventPage()),
                     ); // Close the drawer
                    // Do something
                  },
                ),
                ListTile(
                  leading: Icon(Icons.calendar_month_rounded),
                  title: Text('Attendance'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AttendancePage()),
                     ); // Close the drawer
                    // Navigate to settings
                  },
                ),
                ListTile(
                  leading: Icon(Icons.map),
                  title: Text('Map'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MapPage()),
                     ); // Close the drawer
                    // Do something
                  },
                ),
                ListTile(
                  leading: Icon(Icons.mic),
                  title: Text('Party Tickets'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PartyPage()),
                     ); // Close the drawer
                    // Do something
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Home Page',
        ),
      ),
    );
  }
}