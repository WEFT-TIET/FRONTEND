import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/home/view/pages/home_page.dart';
import 'package:frontend_weft/features/messages/view/pages/message_page.dart';
import 'package:frontend_weft/features/profile/pages/profile_page.dart';
import 'package:frontend_weft/features/search/view/pages/search.dart';
import 'package:frontend_weft/features/navbar/gradient_icon.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

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
  double _dialRotation = 0.0;
  double _lastPanAngle = 0.0;
  bool _isDragging = false;

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
    
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _expandAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleDial() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  void _updateSelectedIndex() {
    // Calculate which section is currently selected based on rotation
    double normalizedRotation = (_dialRotation % (2 * math.pi)) / (2 * math.pi);
    if (normalizedRotation < 0) normalizedRotation += 1;
    
    int newIndex = ((normalizedRotation * _navItems.length) + 0.5).floor() % _navItems.length;
    
    if (newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (!_isExpanded) return;
    
    setState(() {
      _isDragging = true;
    });
    
    final center = Offset(75, 75); // Center of the dial
    final offset = details.localPosition - center;
    _lastPanAngle = math.atan2(offset.dy, offset.dx);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isExpanded) return;

    final center = Offset(75, 75);
    final offset = details.localPosition - center;
    final angle = math.atan2(offset.dy, offset.dx);
    
    double deltaAngle = angle - _lastPanAngle;
    
    // Handle angle wrapping
    if (deltaAngle > math.pi) {
      deltaAngle -= 2 * math.pi;
    } else if (deltaAngle < -math.pi) {
      deltaAngle += 2 * math.pi;
    }
    
    setState(() {
      _dialRotation += deltaAngle;
    });
    
    _lastPanAngle = angle;
    _updateSelectedIndex();
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  Widget _buildCollapsedDial() {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32.5),
          onTap: _toggleDial,
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
            child: Icon(
              Icons.menu,
              color: AppPallete.gradient2,
              size: 28,
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
        return Opacity(
          opacity: _expandAnimation.value,
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onTap: _toggleDial,
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                children: [
                  // Outer dial ring
                  Container(
                    width: 160,
                    height: 160,
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
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                  
                  // Rotatable inner dial
                  Center(
                    child: Transform.rotate(
                      angle: _dialRotation,
                      child: Container(
                        width: 130,
                        height: 130,
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
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: _navItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final angle = (index * 2 * math.pi) / _navItems.length - math.pi / 2;
                            final radius = 38.0;
                            
                            return Positioned(
                              left: 65 + math.cos(angle) * radius - 18,
                              top: 65 + math.sin(angle) * radius - 18,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 36,
                                height: 36,
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
                                            Colors.white.withOpacity(0.5),
                                            Colors.white.withOpacity(0.3),
                                          ],
                                        ),
                                  border: Border.all(
                                    color: _selectedIndex == index 
                                        ? Colors.white.withOpacity(0.8)
                                        : AppPallete.greyColor.withOpacity(0.3),
                                    width: _selectedIndex == index ? 2 : 1,
                                  ),
                                ),
                                child: _selectedIndex == index
                                    ? Icon(
                                        item.activeIcon,
                                        size: 20,
                                        color: Colors.white,
                                      )
                                    : Icon(
                                        item.icon,
                                        size: 18,
                                        color: AppPallete.greyColor.withOpacity(0.7),
                                      ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  
                  // Center indicator dot
                  Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            AppPallete.gradient1,
                            AppPallete.gradient2,
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  
                  // Selection indicator line
                  Center(
                    child: Transform.rotate(
                      angle: -math.pi / 2,
                      child: Container(
                        width: 3,
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppPallete.gradient1,
                              AppPallete.gradient2,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  
                  // Rotation hint
                  if (_isDragging) ...[
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'Rotate to navigate',
                            style: GoogleFonts.oswald(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.transperantColor,
      body: Container(
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
      floatingActionButton: _isExpanded ? _buildExpandedDial() : _buildCollapsedDial(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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