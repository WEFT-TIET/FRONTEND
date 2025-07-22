import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/home/view/pages/home_page.dart';
import 'package:frontend_weft/features/messages/view/pages/message.dart';
import 'package:frontend_weft/features/profile/pages/profile_page.dart';
// import 'package:frontend_weft/features/search/view/pages/search.dart';
import 'package:frontend_weft/features/navbar/gradient_icon.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavBar extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  const BottomNavBar({super.key, this.onThemeToggle});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  // Static pages list - fully const for maximum optimization
  static const List<Widget> _pages = [
    HomePage(),
    // SearchPage(),
    MessagePage(),
    ProfilePage(),
  ];

  // Pre-computed static decorations to avoid recreation
  static final BoxDecoration _activeDecoration = BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(colors: [
      AppPallete.gradient2.withOpacity(0.3),
      AppPallete.gradient3.withOpacity(0.3),
    ]),
  );

  static const BoxDecoration _inactiveDecoration = BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.transparent,
  );

  // Cached gradient
  static const LinearGradient _iconGradient = LinearGradient(colors: [
    AppPallete.gradient1,
    AppPallete.gradient2,
    AppPallete.gradient3,
  ]);

  // Pre-computed text styles as static
  static final TextStyle _activeTextStyle = GoogleFonts.oswald(
    color: AppPallete.gradient2,
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle _inactiveTextStyle = GoogleFonts.oswald(
    color: AppPallete.greyColor,
    fontSize: 8,
  );

  // Navigation items with const constructor
  static const List<_NavItemData> _navItems = [
    _NavItemData(Icons.home_outlined, Icons.home_filled, 'Home'),
    _NavItemData(Icons.search_outlined, Icons.search, 'Search'),
    _NavItemData(Icons.chat_bubble_outline_rounded, Icons.chat_bubble, 'Messages'),
    _NavItemData(Icons.person_outline, Icons.person, 'Profile'),
  ];

  // Pre-built inactive icons to avoid recreation
  late final List<Widget> _inactiveIcons;
  late final List<Widget> _activeIcons;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Pre-build all icon widgets to avoid recreation
    _inactiveIcons = List.generate(_navItems.length, (index) {
      return Icon(
        _navItems[index].icon,
        size: 24,
        color: AppPallete.greyColor,
        key: ValueKey('inactive_$index'),
      );
    });

    _activeIcons = List.generate(_navItems.length, (index) {
      return GradientIcon(
        icon: _navItems[index].activeIcon,
        gradient: _iconGradient,
        size: 24,
        key: ValueKey('active_$index'),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
      _animationController.forward().then((_) {
        _animationController.reset();
      });
    }
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: RepaintBoundary( // Isolate repaints
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(6),
                decoration: isSelected ? _activeDecoration : _inactiveDecoration,
                child: isSelected ? _activeIcons[index] : _inactiveIcons[index],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: isSelected ? _activeTextStyle : _inactiveTextStyle,
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.transperantColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: RepaintBoundary( // Isolate bottom nav repaints
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.3),
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            child: Container(
              height: 70,
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
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: List.generate(
                      _navItems.length,
                      _buildNavItem,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Immutable data class with const constructor
@immutable
class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  
  const _NavItemData(this.icon, this.activeIcon, this.label);
}