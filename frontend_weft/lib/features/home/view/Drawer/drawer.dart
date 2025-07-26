import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/home/view/Drawer/attendance.dart';
import 'package:frontend_weft/features/home/view/Drawer/soc_page/pages/society_page.dart';
import 'package:frontend_weft/features/home/view/Drawer/map.dart';
import 'package:frontend_weft/features/home/view/Drawer/party.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: SizedBox(
            width: 280,
            child: Drawer(
              backgroundColor: AppPallete.profileBackgroundDark,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  // Header
                  Container(
                    height: 100,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppPallete.gradient1, AppPallete.gradient2],
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
                          page: SocietyPage(),
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
        );
  }

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
        border: Border.all(color: AppPallete.glassWhite10, width: 1),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppPallete.profileAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppPallete.profileAccent, size: 20),
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