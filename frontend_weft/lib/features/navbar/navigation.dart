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
  late AnimationController _circleController;
  late Animation<double> _slideAnimation;
  late Animation<double> _circleAnimation;
  
  bool _isSliding = false;
  bool _isSliderVisible = false;
  
  // Circle position - starts at bottom left
  double _circleX = 16.0;
  double _circleY = 0.0; // Will be set in initState
  double _startDragX = 0.0;
  double _startDragY = 0.0;
  
  // Slider dimensions
  static const double _sliderHeight = 85.0; // Slightly larger than circle
  static const double _circleSize = 65.0;
  static const double _circlePadding = 16.0;
  
  // Navigation thresholds - will be calculated based on screen width
  double _homeThreshold = 0.0;
  double _searchThreshold = 0.0;
  double _messagesThreshold = 0.0;
  double _profileThreshold = 0.0;

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
        
        // Calculate navigation thresholds based on screen width
        final availableWidth = screenSize.width - _circleSize - (_circlePadding * 2);
        _homeThreshold = availableWidth * 0.25;
        _searchThreshold = availableWidth * 0.5;
        _messagesThreshold = availableWidth * 0.75;
        _profileThreshold = availableWidth;
      });
    });
    
    // Slide animation controller
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800), // Increased from 600ms
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart, // Changed from easeOutCubic for smoother motion
    ));
    
    // Circle animation controller
    _circleController = AnimationController(
      duration: const Duration(milliseconds: 700), // Increased from 500ms
      vsync: this,
    );

    _circleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _circleController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isSliding = true;
      _startDragX = details.globalPosition.dx;
      _startDragY = details.globalPosition.dy;
    });
    
    if (!_isSliderVisible) {
      _slideController.forward();
      setState(() {
        _isSliderVisible = true;
      });
    }
    
    HapticFeedback.lightImpact();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isSliding) return;
    
    final deltaX = details.globalPosition.dx - _startDragX;
    
    // Calculate current position and page boundaries
    final relativePosition = _circleX - _circlePadding;
    final currentPage = _getCurrentPage(relativePosition);
    
    // Reduce sensitivity even more and add drag at page boundaries
    double sensitivity = 0.3; // Reduced from 0.5 to 0.3 (30% sensitivity)
    
    // Add extra drag when near page boundaries
    if (_isNearPageBoundary(relativePosition, currentPage)) {
      sensitivity *= 0.3; // 70% additional drag at boundaries (30% of 30% = 9% total sensitivity)
      // Add vibration feedback when entering drag zone
      HapticFeedback.lightImpact();
    }
    
    final newX = _circleX + (deltaX * sensitivity);
    
    // Limit sliding to full screen width
    final maxSlideX = MediaQuery.of(context).size.width - _circleSize - _circlePadding;
    final clampedX = newX.clamp(_circlePadding, maxSlideX);
    
    setState(() {
      _circleX = clampedX;
    });
    
    // Calculate which page to show based on position using thresholds
    final newRelativePosition = _circleX - _circlePadding;
    
    int newIndex = _selectedIndex;
    if (newRelativePosition < _homeThreshold) {
      newIndex = 0; // Home
    } else if (newRelativePosition < _searchThreshold) {
      newIndex = 1; // Search
    } else if (newRelativePosition < _messagesThreshold) {
      newIndex = 2; // Messages
    } else {
      newIndex = 3; // Profile
    }
    
    if (newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
      // Add stronger vibration feedback when switching pages
      HapticFeedback.heavyImpact();
    }
  }
  
  // Helper method to get current page based on position
  int _getCurrentPage(double relativePosition) {
    if (relativePosition < _homeThreshold) return 0;
    if (relativePosition < _searchThreshold) return 1;
    if (relativePosition < _messagesThreshold) return 2;
    return 3;
  }
  
  // Helper method to check if near page boundary
  bool _isNearPageBoundary(double relativePosition, int currentPage) {
    final boundaryZone = 30.0; // 30px zone around each boundary
    
    switch (currentPage) {
      case 0: // Home
        return relativePosition > (_homeThreshold - boundaryZone);
      case 1: // Search
        return relativePosition < (_searchThreshold + boundaryZone) && 
               relativePosition > (_searchThreshold - boundaryZone);
      case 2: // Messages
        return relativePosition < (_messagesThreshold + boundaryZone) && 
               relativePosition > (_messagesThreshold - boundaryZone);
      case 3: // Profile
        return relativePosition < (_profileThreshold + boundaryZone) && 
               relativePosition > (_profileThreshold - boundaryZone);
      default:
        return false;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isSliding = false;
    });
    
    // Animate circle back to initial position
    _circleController.forward().then((_) {
      setState(() {
        _circleX = _circlePadding; // Return to left edge with padding
      });
      _circleController.reverse();
    });
    
    // Hide slider after a delay
    Future.delayed(const Duration(milliseconds: 800), () { // Increased from 500ms
      if (!_isSliding) {
        _slideController.reverse();
        setState(() {
          _isSliderVisible = false;
        });
      }
    });
    
    HapticFeedback.mediumImpact();
  }

  void _onCircleTap() {
    // If at initial position, go to home
    if (_circleX <= _circlePadding + 5) {
      setState(() {
        _selectedIndex = 0;
      });
      HapticFeedback.selectionClick();
    }
  }

  Widget _buildSliderTrack() {
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
                    child: Stack(
                      children: [
                        // Navigation indicators positioned equally across full screen width
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.125,
                          top: _sliderHeight / 2 - 15,
                          child: _buildNavIndicator(0, _navItems[0]),
                        ),
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.375,
                          top: _sliderHeight / 2 - 15,
                          child: _buildNavIndicator(1, _navItems[1]),
                        ),
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.625,
                          top: _sliderHeight / 2 - 15,
                          child: _buildNavIndicator(2, _navItems[2]),
                        ),
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.875,
                          top: _sliderHeight / 2 - 15,
                          child: _buildNavIndicator(3, _navItems[3]),
                        ),
                      ],
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

  Widget _buildNavIndicator(int index, _NavItemData item) {
    final isSelected = _selectedIndex == index;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 30,
      height: 30,
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
        size: 16,
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
      ),
    );
  }

  Widget _buildSlidingCircle() {
    return AnimatedBuilder(
      animation: _circleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_circleAnimation.value * 0.1),
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onTap: _onCircleTap,
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
          ),
        );
      },
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
          
          // Slider track - positioned at bottom left, not covering entire screen
          if (_isSliderVisible)
            Positioned(
              left: 0, // Start from left edge
              bottom: _circlePadding, // Use bottom instead of top
              child: _buildSliderTrack(),
            ),
          
          // Sliding circle - positioned relative to slider
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500), // Increased from 300ms
            curve: Curves.easeOutCubic, // Changed from easeOutCubic for smoother motion
            left: _circleX,
            bottom: _circlePadding + (_sliderHeight - _circleSize) / 2, // Center in slider, use bottom
            child: _buildSlidingCircle(),
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