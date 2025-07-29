import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/home/view/pages/home_page.dart';
import 'package:frontend_weft/features/messages/view/pages/message_page.dart';
import 'package:frontend_weft/features/profile/pages/profile_page.dart';
import 'package:frontend_weft/features/search/view/pages/search.dart';

class BottomNavBar extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  const BottomNavBar({super.key, this.onThemeToggle});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  
  bool _isExpanded = false;
  
  // Position variables for dragging - start at bottom left
  double _xPosition = 16.0;
  double _yPosition = 0.0; // Will be set to bottom in initState
  double _originalXPosition = 16.0; // Store original position before centering
  double _originalYPosition = 0.0; // Store original Y position before centering
  
  // Default/reset position - easily changeable for future (bottom left to bottom right)
  double get _defaultXPosition => 16.0; // Change to (MediaQuery.of(context).size.width - 81) for bottom right
  double get _defaultYFromBottom => 81.0; // 65 (circle height) + 16 (padding)

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
    
    // Set initial position to bottom left after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        _yPosition = screenSize.height - _defaultYFromBottom;
        _originalYPosition = _yPosition;
        _xPosition = _defaultXPosition;
        _originalXPosition = _xPosition;
      });
    });
    
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      // Store current position before centering
      _originalXPosition = _xPosition;
      _originalYPosition = _yPosition;
      // Move to center horizontally only, keep same Y position
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        _xPosition = (screenSize.width - 65) / 2; // Center horizontally
        // Keep _yPosition the same - don't change vertical position
      });
      _expandController.forward();
      HapticFeedback.lightImpact();
    } else {
      // Return to original position when collapsing
      setState(() {
        _xPosition = _originalXPosition;
        _yPosition = _originalYPosition;
      });
      _expandController.reverse();
      HapticFeedback.lightImpact();
    }
  }

  void _resetToDefaultPosition() {
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      _xPosition = _defaultXPosition; // For bottom right: use (screenSize.width - 81)
      _yPosition = screenSize.height - _defaultYFromBottom;
      _originalXPosition = _xPosition;
      _originalYPosition = _yPosition;
      _isExpanded = false;
    });
    _expandController.reverse();
    HapticFeedback.mediumImpact();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
      _isExpanded = false;
    });
    
    // Return to original position when collapsing via page selection
    setState(() {
      _xPosition = _originalXPosition;
      _yPosition = _originalYPosition;
    });
    
    _expandController.reverse();
    HapticFeedback.selectionClick();
  }

  Widget _buildCollapsedDial() {
    return Draggable(
      feedback: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.8),
              Colors.white.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppPallete.gradient2.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      childWhenDragging: Container(),
      onDragEnd: (details) {
        final screenSize = MediaQuery.of(context).size;
        setState(() {
          _xPosition = (details.offset.dx - 32.5).clamp(0.0, screenSize.width - 65);
          _yPosition = (details.offset.dy - 32.5).clamp(0.0, screenSize.height - 65);
          _originalXPosition = _xPosition; // Update original position after drag
          _originalYPosition = _yPosition; // Update original Y position after drag
        });
      },
      child: GestureDetector(
        onTap: _toggleExpansion,
        onDoubleTap: _resetToDefaultPosition, // Double tap to reset to bottom left
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.8),
                Colors.white.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppPallete.gradient2.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedDial() {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final animationValue = _expandAnimation.value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: animationValue,
          child: Opacity(
            opacity: animationValue,
            child: SizedBox(
              width: 200,
              height: 120,
              child: Stack(
                children: [
                  // Center circle - NOT draggable when expanded
                  Positioned(
                    bottom: 0,
                    left: 67.5, // Center in 200px width
                    child: GestureDetector(
                      onTap: _toggleExpansion,
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.8),
                            ],
                          ),
                          border: Border.all(
                            color: AppPallete.gradient2.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Home icon (far left)
                  Positioned(
                    left: 20,
                    bottom: 55,
                    child: _buildNavIcon(0, _navItems[0]),
                  ),
                  
                  // Search icon (left-center)  
                  Positioned(
                    left: 60,
                    bottom: 75,
                    child: _buildNavIcon(1, _navItems[1]),
                  ),
                  
                  // Messages icon (right-center)
                  Positioned(
                    right: 60,
                    bottom: 75,
                    child: _buildNavIcon(2, _navItems[2]),
                  ),
                  
                  // Profile icon (far right)
                  Positioned(
                    right: 20,
                    bottom: 55,
                    child: _buildNavIcon(3, _navItems[3]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavIcon(int index, _NavItemData item) {
    return GestureDetector(
      onTap: () => _selectPage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _selectedIndex == index 
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
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.8),
                  ],
                ),
          border: Border.all(
            color: _selectedIndex == index 
                ? Colors.white.withOpacity(0.8)
                : AppPallete.gradient2.withOpacity(0.3),
            width: _selectedIndex == index ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _selectedIndex == index 
                  ? AppPallete.gradient2.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          _selectedIndex == index ? item.activeIcon : item.icon,
          size: 20,
          color: _selectedIndex == index 
              ? Colors.white
              : AppPallete.gradient2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Set default position to bottom left if not set
    if (_yPosition == 0.0) {
      _yPosition = screenSize.height - _defaultYFromBottom;
      _originalYPosition = _yPosition;
      _xPosition = _defaultXPosition;
      _originalXPosition = _xPosition;
    }
    
    // Ensure position is within screen bounds - allow full width for extreme right
    _xPosition = _xPosition.clamp(0.0, screenSize.width - 65);
    _yPosition = _yPosition.clamp(0.0, screenSize.height - 65);
    
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
          
          // Backdrop when expanded
          if (_isExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleExpansion,
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
            ),
          
          // Floating Action Button positioned dynamically
          Positioned(
            left: _isExpanded ? (screenSize.width - 200) / 2 : _xPosition, // Center expanded dial
            top: _yPosition,
            child: _isExpanded ? _buildExpandedDial() : _buildCollapsedDial(),
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