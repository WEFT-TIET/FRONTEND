import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/home/view/pages/home_page.dart';
import 'package:frontend_weft/features/messages/view/pages/message.dart';
import 'package:frontend_weft/features/profile/pages/profile_page.dart';
import 'package:frontend_weft/features/search/view/pages/search.dart';
import 'package:frontend_weft/features/navbar/gradient_icon.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavBar extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  const BottomNavBar({super.key, this.onThemeToggle});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomePage(),
    SearchPage(),
    // MessagePage(),
    ProfilePage(),
  ];

  // Color scheme
  static const Color activeIconColor = AppPallete.gradient1;
  static const Color activeTextColor = AppPallete.gradient2;
  static final Color inactiveColor = AppPallete.greyColor;
  static const List<Color> gradientColors = [
    AppPallete.gradient1,
    AppPallete.gradient2,
    AppPallete.gradient3,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.transperantColor,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppPallete.blackColor.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppPallete.blackColor.withOpacity(0.9),
                  AppPallete.blackColor.withOpacity(0.95),
                ],
              ),
              border: Border.all(
                color: AppPallete.greyColor.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                elevation: 0,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: Colors.transparent,
                selectedItemColor: activeIconColor,
                unselectedItemColor: inactiveColor,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedLabelStyle: GoogleFonts.getFont(
                  'Oswald',
                  color: activeTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: GoogleFonts.getFont(
                  'Oswald',
                  color: inactiveColor,
                  fontSize: 12,
                ),
                iconSize: 28,
                items: [
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedIndex == 0
                            ? AppPallete.gradient1.withOpacity(0.2)
                            : Colors.transparent,
                      ),
                      child: const Icon(Icons.home_outlined),
                    ),
                    activeIcon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [
                          AppPallete.gradient1.withOpacity(0.3),
                          AppPallete.gradient2.withOpacity(0.3),
                        ]),
                      ),
                      child: const GradientIcon(
                        icon: Icons.home_filled,
                        gradient: LinearGradient(colors: gradientColors),
                        size: 28,
                      ),
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedIndex == 1
                            ? AppPallete.gradient1.withOpacity(0.2)
                            : Colors.transparent,
                      ),
                      child: const Icon(Icons.search_outlined),
                    ),
                    activeIcon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [
                          AppPallete.gradient1.withOpacity(0.3),
                          AppPallete.gradient2.withOpacity(0.3),
                        ]),
                      ),
                      child: const GradientIcon(
                        icon: Icons.search,
                        gradient: LinearGradient(colors: gradientColors),
                        size: 28,
                      ),
                    ),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedIndex == 2
                            ? AppPallete.gradient1.withOpacity(0.2)
                            : Colors.transparent,
                      ),
                      child: const Icon(Icons.person_outline),
                    ),
                    activeIcon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [
                          AppPallete.gradient1.withOpacity(0.3),
                          AppPallete.gradient2.withOpacity(0.3),
                        ]),
                      ),
                      child: const GradientIcon(
                        icon: Icons.person,
                        gradient: LinearGradient(colors: gradientColors),
                        size: 28,
                      ),
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}