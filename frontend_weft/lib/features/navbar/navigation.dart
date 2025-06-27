import 'package:flutter/material.dart';
import 'package:frontend_weft/features/home/view/pages/home.dart';
import 'package:frontend_weft/features/messages/view/pages/message.dart';
import 'package:frontend_weft/features/profile/view/pages/profile.dart';
import 'package:frontend_weft/features/search/view/pages/search.dart';
import 'package:frontend_weft/features/navbar/gradient_icon.dart';

class BottomNavBar extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  const BottomNavBar({super.key, this.onThemeToggle});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[
    HomePage(),
    SearchPage(),
    MessagePage(),
    ProfilePage(),
  ];

  // Color constants
  static const Color backgroundColor = Colors.black;
  
  static const Color activeIconColor = Color(0xFF3B82F6);
  static const Color activeTextColor = Color(0xFF60A5FA);
  static const Color inactiveColor = Color(0xFF6B7280);
  static const List<Color> gradientColors = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
    decoration: BoxDecoration(
          
         
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24), 
          child: Theme(
             data: Theme.of(context).copyWith(
        splashColor: Colors.transparent, // Remove splash effect
        highlightColor: Colors.transparent, // Remove highlight effect
      ),
            child: BottomNavigationBar(
              elevation: 0, // Remove default shadow
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: backgroundColor,
              selectedItemColor: activeIconColor,
              unselectedItemColor: inactiveColor,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(
                color: activeTextColor,
                fontSize: 10, 
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 10, 
              ),
              iconSize: 24, 
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: GradientIcon(
                    icon: Icons.home_outlined,
                    gradient: LinearGradient(colors: gradientColors),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined),
                  activeIcon: GradientIcon(
                    icon: Icons.search_outlined,
                    gradient: LinearGradient(colors: gradientColors),
                  ),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline),
                  activeIcon: GradientIcon(
                    icon: Icons.forum_outlined,
                    gradient: LinearGradient(colors: gradientColors),
                  ),
                  label: 'Message',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: GradientIcon(
                    icon: Icons.person_outline,
                    gradient: LinearGradient(colors: gradientColors),
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}