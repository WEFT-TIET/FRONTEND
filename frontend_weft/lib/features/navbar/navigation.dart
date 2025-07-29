import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/home/view/pages/home_page.dart';
import 'package:frontend_weft/features/messages/view/pages/message_page.dart';
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
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  
  bool _isNavbarVisible = false;
  
  // Circle position - starts at bottom left
  double _circleX = 16.0;
  double _circleY = 0.0; // Will be set in initState
  
  // Slider dimensions
  static const double _sliderHeight = 85.0; // Slightly larger than circle
  static const double _circleSize = 65.0;
  static const double _circlePadding = 16.0;

  // Static pages list
  static const List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    MessagePage(),
    ProfilePage(),
  ];

  // Navigation items data
  static const List<_NavItemData> _navItems = [
    _NavItemData(Icons.home_outlined, Icons.home_filled, 'Home'),
    _NavItemData(Icons.search_outlined, Icons.search, 'Search'),
    _NavItemData(Icons.chat_bubble_outline_rounded, Icons.chat_bubble, 'Messages'),
    _NavItemData(Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    
    // Set initial circle position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        _circleY = screenSize.height - _sliderHeight - _circlePadding;
        _circleX = _circlePadding; // Start from left edge with padding
      });
    });
    
    // Slide animation controller
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _toggleNavbar() {
    setState(() {
      _isNavbarVisible = !_isNavbarVisible;
    });
    
    if (_isNavbarVisible) {
      _slideController.forward();
      HapticFeedback.lightImpact();
    } else {
      _slideController.reverse();
      HapticFeedback.lightImpact();
    }
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
      _isNavbarVisible = false;
    });
    
    _slideController.reverse();
    HapticFeedback.selectionClick();
  }

  Widget _buildNavbar() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _slideAnimation.value,
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Container(
              width: MediaQuery.of(context).size.width,
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, _NavItemData item) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _selectPage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 50,
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
          size: 24,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildCircle() {
    return GestureDetector(
      onTap: _toggleNavbar,
      child: Container(
        width: _circleSize,
        height: _circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.95),
              Colors.white.withOpacity(0.85),
              Colors.white.withOpacity(0.75),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppPallete.gradient2.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            _navItems[_selectedIndex].activeIcon,
            size: 24,
            color: AppPallete.gradient2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Set initial circle position if not set
    if (_circleY == 0.0) {
      _circleY = screenSize.height - _sliderHeight - _circlePadding;
    }
    
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
          
          // Backdrop to close navbar when tapping outside
          if (_isNavbarVisible)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isNavbarVisible = false;
                  });
                  _slideController.reverse();
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          
          // Navbar - positioned at bottom
          if (_isNavbarVisible)
            Positioned(
              left: 0,
              bottom: _circlePadding,
              child: _buildNavbar(),
            ),
          
          // Circle - positioned at bottom left (hidden when navbar is open)
          if (!_isNavbarVisible)
            Positioned(
              left: _circleX,
              bottom: _circlePadding + (_sliderHeight - _circleSize) / 2,
              child: _buildCircle(),
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