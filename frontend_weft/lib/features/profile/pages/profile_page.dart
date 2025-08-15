import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/core/utils/responsive_utils.dart';
import 'package:frontend_weft/core/utils/responsive_text_styles.dart';
import 'package:frontend_weft/core/widgets/responsive_profile_name.dart';
import 'package:frontend_weft/features/post/view/pages/create_post_page.dart';
import 'package:frontend_weft/features/profile/models/user_model.dart';
import 'package:frontend_weft/features/profile/services/profile_api_service.dart';
import 'package:frontend_weft/features/profile/widgets/profile_dialogs.dart';
import 'package:frontend_weft/features/profile/widgets/profile_image_viewer.dart';
import 'package:frontend_weft/features/profile/pages/skills_management_page.dart';
import 'package:frontend_weft/features/profile/pages/edit_profile_page.dart';
import 'package:frontend_weft/features/post/view/widgets/post_card.dart';
import 'package:url_launcher/url_launcher.dart';

final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final api = ref.read(profileApiServiceProvider);
  return await api.getUserProfile();
});

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    });
  }

  Widget? _buildCustomBackButton(BuildContext context) {
    // Check if we can pop and if we should show the back button
    if (Navigator.of(context).canPop()) {
      // Get the previous route name from the Navigator
      final modalRoute = ModalRoute.of(context);
      final routeName = modalRoute?.settings.name;
      
      // Don't show back button if we're coming from auth screens or if this is the home route
      if (routeName == '/home' || routeName == '/welcome' || routeName == '/login' || 
          routeName?.contains('signup') == true) {
        return null; // No back button
      }
      
      // Show back button for legitimate navigation (e.g., from post details, search results, etc.)
      return IconButton(
        icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
    }
    return null; // No back button if we can't pop
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userProfileAsync = ref.watch(userProfileProvider);

    return Container(
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
      child: Scaffold(
        backgroundColor: AppPallete.transperantColor,
        appBar: AppBar(
          backgroundColor: AppPallete.transperantColor,
          elevation: 0,
          leading: _buildCustomBackButton(context),
          title: Text(
            'WEFT',
            style: ResponsiveTextStyles.getHeading1(context).copyWith(
              color: AppPallete.textPrimaryDark,
              letterSpacing: 2,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.settings, 
                color: AppPallete.textPrimaryDark,
                size: context.responsiveIconSize(24),
              ),
              onPressed: () => Navigator.of(context).pushNamed('/settings'),
            ),
          ],
        ),
        body: userProfileAsync.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text('No profile data found'));
            }
            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // Profile Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: context.responsivePadding(),
                        child: RepaintBoundary(
                          child: _buildOptimizedProfileCard(user),
                        ),
                      ),
                    ),
                    
                    // Section Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          context.responsiveSpacing(16), 
                          context.responsiveSpacing(16), 
                          context.responsiveSpacing(16), 
                          context.responsiveSpacing(8)
                        ),
                        child: RepaintBoundary(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Your Wefs',
                                style: ResponsiveTextStyles.getHeading2(context).copyWith(
                                  color: AppPallete.textPrimaryDark,
                                ),
                              ),
                              Row(
                                children: [
                                  // Enhanced Create Weft Button
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const CreatePostPage(),
                                          ),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: context.responsiveSpacing(12),
                                            vertical: context.responsiveSpacing(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.edit_note,
                                                color: Colors.white,
                                                size: context.responsiveIconSize(20),
                                              ),
                                              SizedBox(width: context.responsiveSpacing(6)),
                                              Text(
                                                'Post Weft',
                                                style: ResponsiveTextStyles.getBodyMedium(context).copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: context.responsiveSpacing(8)),
                                  IconButton(
                                    icon: Icon(
                                      Icons.refresh, 
                                      color: AppPallete.textPrimaryDark,
                                      size: context.responsiveIconSize(24),
                                    ),
                                    tooltip: 'Refresh',
                                    onPressed: () {
                                      setState(() => _isLoading = true);
                                      ref.invalidate(userProfileProvider);
                                      Future.delayed(const Duration(milliseconds: 800), () {
                                        if (mounted) setState(() => _isLoading = false);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Posts List
                    user.posts.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: context.responsiveSpacing(32)),
                              child: RepaintBoundary(
                                child: Center(
                                  child: Text(
                                    'No wefts yet.',
                                    style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
                                      color: AppPallete.textPrimaryDark.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final sortedPosts = List.of(user.posts)
                                    ..sort((a, b) {
                                      final aDate = DateTime.tryParse(a.createdAt) ?? DateTime(1970);
                                      final bDate = DateTime.tryParse(b.createdAt) ?? DateTime(1970);
                                      return bDate.compareTo(aDate);
                                    });
                                  final post = sortedPosts[index];
                                  return RepaintBoundary(
                                    child: PostCard(
                                      postId: post.id,
                                      userId: post.userId,
                                      username: post.username.isNotEmpty ? post.username : user.name,
                                      tag: post.title,
                                      timeAgo: _formatTimeAgo(post.createdAt),
                                      content: post.content,
                                      stars: post.likesCount,
                                      comments: post.commentsCount,
                                      liked: post.liked,
                                      showMenu: true, // Enable menu for profile posts
                                      verified: user.isVerified,
                                      onPostDeleted: () {
                                        // Refresh profile data when post is deleted
                                        ref.invalidate(userProfileProvider);
                                      },
                                    ),
                                  );
                                },
                                childCount: user.posts.length,
                                addAutomaticKeepAlives: true,
                                addRepaintBoundaries: true,
                              ),
                            ),
                          ),
                    
                    // Bottom padding
                    SliverToBoxAdapter(
                      child: SizedBox(height: context.responsiveSpacing(80)),
                    ),
                  ],
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppPallete.textPrimaryDark),
                      ),
                    ),
                  ),
                if (_errorMessage != null)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.red.withValues(alpha: 0.8),
                      child: Text(_errorMessage!, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  // ENHANCED PROFILE CARD WITH MAP THEME
  Widget _buildOptimizedProfileCard(UserModel user) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: context.responsivePadding(),
      decoration: BoxDecoration(
        borderRadius: context.responsiveBorderRadius(20),
        // Darker glassmorphism effect
        color: const Color(0xFF2A2D5A).withValues(alpha: 0.8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileHeader(user),
          SizedBox(height: context.responsiveSpacing(12)),
          _buildAcademicDetails(user),
          SizedBox(height: context.responsiveSpacing(12)),
          _buildActionButtons(user),
        ],
      ),
    );
  }

  // ENHANCED PROFILE HEADER
  Widget _buildProfileHeader(UserModel user) {
    final profileImageSize = ResponsiveUtils.getProfileImageSize(context);
    
    return Row(
      children: [
        Hero(
          tag: 'profile_image',
          child: GestureDetector(
            onTap: () {
              showProfileImageViewer(
                context,
                imageUrl: user.imageUrl,
                userName: user.name,
                onEditPressed: () => _navigateToEditProfile(user),
                isEditing: false,
              );
            },
            child: Container(
              width: profileImageSize,
              height: profileImageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Enhanced glassmorphism for profile image
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipOval(
                child: (user.imageUrl != null && user.imageUrl!.startsWith('http'))
                    ? Image.network(
                        user.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                      )
                    : Image.asset(
                        user.imageUrl ?? 'lib/core/assets/profile_photo.jpeg',
                        fit: BoxFit.cover,
                        cacheWidth: 200,
                        cacheHeight: 200,
                        errorBuilder: (_, error, stackTrace) => _buildDefaultAvatar(),
                      ),
              ),
            ),
          ),
        ),
        SizedBox(width: context.responsiveSpacing(20)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ResponsiveProfileName(
                                key: const ValueKey('profile_name'),
                                name: user.name,
                                isVerified: user.isVerified,
                                color: Colors.white,
                                maxLength: 20, // Set character limit
                                onNameTooLong: () {
                                  // Show error snackbar when name is too long
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Profile name is too long (max 20 characters). Consider updating it.',
                                        style: ResponsiveTextStyles.getBodyMedium(context),
                                      ),
                                      backgroundColor: AppPallete.red.withValues(alpha: 0.9),
                                      duration: const Duration(seconds: 3),
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(context.responsiveSpacing(16)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: context.responsiveBorderRadius(12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Show name length indicator if name is getting long
                              if (user.name.length > 15)
                                Padding(
                                  padding: EdgeInsets.only(top: context.responsiveSpacing(4)),
                                  child: Text(
                                    '${user.name.length}/20 characters',
                                    style: ResponsiveTextStyles.getCaption(context).copyWith(
                                      color: user.name.length > 20 
                                        ? AppPallete.red 
                                        : Colors.white.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: context.responsiveSpacing(6)),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '@${user.username}',
                                key: const ValueKey('username_text'),
                                style: ResponsiveTextStyles.getUsername(context).copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: ResponsiveTextStyles.getUsername(context).fontSize! * 0.9, // Reduce by 10%
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1, // Force single line
                              ),
                              // Show username length indicator if username is getting long
                              if (user.username.length > 12)
                                Padding(
                                  padding: EdgeInsets.only(top: context.responsiveSpacing(2)),
                                  child: Text(
                                    '${user.username.length}/15 characters',
                                    style: ResponsiveTextStyles.getCaption(context).copyWith(
                                      color: user.username.length > 15 
                                        ? AppPallete.red 
                                        : Colors.white.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Skills Icon
                  GestureDetector(
                    onTap: () => _showSkillsDialog(user),
                    child: Container(
                      padding: EdgeInsets.all(context.responsiveSpacing(8)),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                        borderRadius: context.responsiveBorderRadius(10),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stars,
                            color: const Color(0xFF6366F1),
                            size: context.responsiveIconSize(16),
                          ),
                          SizedBox(width: context.responsiveSpacing(4)),
                          Text(
                            '${user.skills.length}',
                            style: ResponsiveTextStyles.getBodySmall(context).copyWith(
                              color: const Color(0xFF6366F1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method for default avatar
  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6366F1).withValues(alpha: 0.3), const Color(0xFF8B5CF6).withValues(alpha: 0.3)],
        ),
      ),
      child: Icon(
        Icons.person,
        color: Colors.white.withValues(alpha: 0.8),
        size: 40,
      ),
    );
  }

  // ENHANCED ACADEMIC DETAILS
  Widget _buildAcademicDetails(UserModel user) {
    return Container(
      padding: context.responsivePadding(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: context.responsiveBorderRadius(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildDetailColumn('Year', user.year)),
          Container(
            width: 1,
            height: context.responsiveHeight(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Expanded(child: _buildDetailColumn('Branch', user.branch)),
          Container(
            width: 1,
            height: context.responsiveHeight(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Expanded(child: _buildInstagramColumn(user)),
        ],
      ),
    );
  }

  // ENHANCED DETAIL COLUMN
  Widget _buildDetailColumn(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: ResponsiveTextStyles.getBodySmall(context).copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: context.responsiveSpacing(4)),
        Text(
          value,
          style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // INSTAGRAM COLUMN WITH CLICK FUNCTIONALITY
  Widget _buildInstagramColumn(UserModel user) {
    return Column(
      children: [
        Text(
          'Instagram',
          style: ResponsiveTextStyles.getBodySmall(context).copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: context.responsiveSpacing(4)),
        GestureDetector(
          onTap: () => _openInstagram(user.instagramId ?? ''),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveSpacing(8), 
              vertical: context.responsiveSpacing(4)
            ),
            decoration: BoxDecoration(
              color: user.instagramId != null && user.instagramId!.isNotEmpty 
                  ? const Color(0xFFE4405F).withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: context.responsiveBorderRadius(8),
              border: user.instagramId != null && user.instagramId!.isNotEmpty 
                  ? Border.all(
                      color: const Color(0xFFE4405F).withValues(alpha: 0.5),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user.instagramId != null && user.instagramId!.isNotEmpty) ...[
                  Icon(
                    Icons.camera_alt,
                    color: const Color(0xFFE4405F),
                    size: context.responsiveIconSize(14),
                  ),
                  SizedBox(width: context.responsiveSpacing(4)),
                ],
                Flexible(
                  child: Text(
                    user.instagramId != null && user.instagramId!.isNotEmpty 
                        ? '@${user.instagramId!}'
                        : 'Not set',
                    style: ResponsiveTextStyles.getBodyMedium(context).copyWith(
                      color: user.instagramId != null && user.instagramId!.isNotEmpty 
                          ? const Color(0xFFE4405F)
                          : Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ENHANCED SKILLS SECTION
  // ENHANCED ACTION BUTTONS
  Widget _buildActionButtons(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Edit',
            Colors.white.withValues(alpha: 0.15),
            Colors.white,
            () => _navigateToEditProfile(user),
            icon: Icons.edit,
          ),
        ),
        SizedBox(width: context.responsiveSpacing(12)),
        Expanded(
          child: _buildActionButton(
            'Share',
            Colors.white.withValues(alpha: 0.15),
            Colors.white,
            _shareProfile,
            icon: Icons.share,
          ),
        ),
      ],
    );
  }

  // ENHANCED ACTION BUTTON
  Widget _buildActionButton(
    String text,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed, {
    IconData? icon,
  }) {
    return Container(
      height: ResponsiveUtils.getButtonHeight(context),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D3A).withValues(alpha: 0.8),
        borderRadius: context.responsiveBorderRadius(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: context.responsiveBorderRadius(12),
          splashColor: Colors.white.withValues(alpha: 0.1),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: context.responsiveSpacing(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: context.responsiveIconSize(18)),
                  SizedBox(width: context.responsiveSpacing(6)),
                ],
                Flexible(
                  child: Text(
                    text,
                    style: ResponsiveTextStyles.getButton(context).copyWith(
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToEditProfile(UserModel user) async {
    HapticFeedback.selectionClick();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: user),
      ),
    );
    
    // If profile was updated, refresh the data
    if (result == true) {
      ref.invalidate(userProfileProvider);
    }
  }

  Future<void> _shareProfile() async {
    HapticFeedback.mediumImpact();
    ProfileDialogs.showSnackBar(context, 'Share feature coming soon!');
  }

  void _showSkillsDialog(UserModel user) async {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SkillsManagementPage(user: user),
      ),
    );
  }

  Future<void> _openInstagram(String instagramId) async {
    if (instagramId.isEmpty) return;
    
    HapticFeedback.selectionClick();
    
    // Remove @ if user added it
    final cleanId = instagramId.replaceFirst('@', '');
    
    // Try to open Instagram app first, then fallback to web
    final appUrl = 'instagram://user?username=$cleanId';
    final webUrl = 'https://instagram.com/$cleanId';
    
    try {
      final Uri appUri = Uri.parse(appUrl);
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else {
        final Uri webUri = Uri.parse(webUrl);
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ProfileDialogs.showSnackBar(context, 'Could not open Instagram profile');
      }
    }
  }

  String _formatTimeAgo(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}