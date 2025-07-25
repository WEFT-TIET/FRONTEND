// File 1: lib/features/profile/widgets/profile_image_viewer.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class ProfileImageViewer extends StatefulWidget {
  final String? imageUrl;
  final String userName;
  final VoidCallback? onEditPressed;
  final bool isEditing;

  const ProfileImageViewer({
    Key? key,
    this.imageUrl,
    required this.userName,
    this.onEditPressed,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<ProfileImageViewer> createState() => _ProfileImageViewerState();
}

class _ProfileImageViewerState extends State<ProfileImageViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeViewer() {
    HapticFeedback.lightImpact();
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _closeViewer,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Stack(
                children: [
                  // Background overlay
                  Container(
                    color: Colors.black.withOpacity(0.9),
                  ),
                  
                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // User name
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Text(
                            widget.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        // Profile image with hero animation
                        Hero(
                          tag: 'profile_image',
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _buildProfileImage(),
                              ),
                            ),
                          ),
                        ),
                        
                        // Edit button (if editing mode)
                        if (widget.isEditing) ...[
                          const SizedBox(height: 32),
                          _buildEditButton(),
                        ],
                        
                        // Instructions
                        const SizedBox(height: 40),
                        Text(
                          'Tap anywhere to close',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Close button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    right: 16,
                    child: _buildCloseButton(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (widget.imageUrl != null && widget.imageUrl!.startsWith('http')) {
      return Image.network(
        widget.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
      );
    } else if (widget.imageUrl != null) {
      return Image.asset(
        widget.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppPallete.cardColorDark.withOpacity(0.3),
      child: Icon(
        Icons.person,
        color: Colors.white.withOpacity(0.7),
        size: 120,
      ),
    );
  }

  Widget _buildCloseButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: _closeViewer,
        icon: const Icon(
          Icons.close,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop();
            widget.onEditPressed?.call();
          },
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Change Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper function to show the profile image viewer
void showProfileImageViewer(
  BuildContext context, {
  String? imageUrl,
  required String userName,
  VoidCallback? onEditPressed,
  bool isEditing = false,
}) {
  HapticFeedback.mediumImpact();
  
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return ProfileImageViewer(
          imageUrl: imageUrl,
          userName: userName,
          onEditPressed: onEditPressed,
          isEditing: isEditing,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 200),
    ),
  );
}

