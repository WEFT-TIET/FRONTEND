import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/home/view/pages/home_page.dart';
import 'package:frontend_weft/features/messages/view/pages/messages_list_page.dart';

import 'package:frontend_weft/features/profile/pages/profile_page.dart';
import 'package:frontend_weft/features/search/view/pages/search.dart';
import 'package:frontend_weft/features/navbar/gradient_icon.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui';

class BottomNavBar extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  const BottomNavBar({super.key, this.onThemeToggle});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  
  // Navbar dimensions
  static const double _sliderHeight = 60.0; // Reduced from 85.0
  static const double _circlePadding = 16.0;

  // Static pages list
  static const List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    MessagesListPage(),
    ProfilePage(),
  ];

  // Navigation items data
  static const List<_NavItemData> _navItems = [
    _NavItemData(Icons.home_outlined, Icons.home_filled, 'Home'),
    _NavItemData(Icons.search_outlined, Icons.search, 'Search'),
    _NavItemData(Icons.chat_bubble_outline_rounded, Icons.chat_bubble, 'Messages'),
    _NavItemData(Icons.person_outline, Icons.person, 'Profile'),
  ];

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    HapticFeedback.selectionClick();
  }

  Widget _buildNavbar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20), // Add horizontal margin
      height: _sliderHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_sliderHeight / 2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_sliderHeight / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_sliderHeight / 2),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_navItems.length, (index) {
                return _buildNavItem(index, _navItems[index]);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, _NavItemData item) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _selectPage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40, // Reduced from 50
        height: 40, // Reduced from 50
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    AppPallete.gradient1,
                    AppPallete.gradient2,
                    AppPallete.gradient3,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.2),
                  ],
                ),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.8)
                : Colors.white.withOpacity(0.4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppPallete.gradient2.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          isSelected ? item.activeIcon : item.icon,
          size: 20, // Reduced from 24
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.transperantColor,
      body: Stack(
        children: [
          // Main content
          Container(
            decoration: const BoxDecoration(
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
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
          
          // Navbar - always visible at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: _circlePadding,
            child: _buildNavbar(),
          ),
        ],
      ),
    );
  }
}

// Immutable data class
@immutable
class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  
  const _NavItemData(this.icon, this.activeIcon, this.label);
}