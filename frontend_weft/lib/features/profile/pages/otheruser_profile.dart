import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/profile/models/other_user_model.dart';
import 'package:frontend_weft/features/profile/widgets/profile_dialogs.dart';
import 'package:frontend_weft/features/profile/widgets/profile_image_viewer.dart';
import 'package:frontend_weft/features/post/view/widgets/post_card.dart';
import 'package:frontend_weft/features/profile/services/profile_api_service.dart';

class OtherUserProfilePage extends ConsumerStatefulWidget {
  final String usernameOrId;
  
  const OtherUserProfilePage({
    super.key,
    required this.usernameOrId,
  });

  @override
  ConsumerState<OtherUserProfilePage> createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends ConsumerState<OtherUserProfilePage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _profileCardKey = GlobalKey();

  bool _isProfileCardPinned = false;
  double _profileCardHeight = 0;

  // Animation controller for smooth transitions
  late AnimationController _animationController;

  bool _isLoading = false;
  String? _errorMessage;

  // User data from API
  OtherUserModel? _userModel;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateProfileCardHeight();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    });
    
    // Fetch user data from API
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profileService = ref.read(profileApiServiceProvider);
      final userData = await profileService.getOtherUserProfile(widget.usernameOrId);
      
      if (userData != null) {
        setState(() {
          _userModel = userData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load user profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: $e';
        _isLoading = false;
      });
    }
  }

  void _calculateProfileCardHeight() {
    final RenderBox? renderBox =
        _profileCardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _profileCardHeight = renderBox.size.height;
      });
    }
  }

  void _onScroll() {
    final shouldPin = _scrollController.offset > _profileCardHeight - 100;
    if (shouldPin != _isProfileCardPinned) {
      setState(() {
        _isProfileCardPinned = shouldPin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
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
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is OverscrollIndicatorNotification) {
                  (notification as OverscrollIndicatorNotification).disallowIndicator();
                }
                return false;
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Custom App Bar
                  SliverAppBar(
                    floating: true,
                    pinned: false,
                    expandedHeight: 60,
                    backgroundColor: AppPallete.transperantColor,
                    elevation: 0,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () => _showOptionsMenu(context),
                        ),
                      ),
                    ],
                  ),
                  
                  // Profile Card
                  if (_userModel != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: RepaintBoundary(
                          key: _profileCardKey,
                          child: _buildOptimizedProfileCard(_userModel!),
                        ),
                      ),
                    ),
                  
                  // Posts Section Header
                  if (_userModel != null)
                    SliverPersistentHeader(
                      pinned: false,
                      floating: true,
                      delegate: _SliverAppBarDelegate(
                        minHeight: 60,
                        maxHeight: 60,
                        child: Container(
                          color: AppPallete.transperantColor,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_userModel!.name}\'s Wefts',
                                style: const TextStyle(
                                  color: AppPallete.textPrimaryDark,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  // Posts List
                  if (_userModel != null)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      sliver: _userModel!.posts.isEmpty
                          ? SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 32.0),
                                child: Center(
                                  child: Text(
                                    'No wefts yet.',
                                    style: TextStyle(
                                      color: AppPallete.textPrimaryDark.withOpacity(0.7),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final sortedPosts = List.of(_userModel!.posts)
                                    ..sort((a, b) {
                                      final aDate = DateTime.tryParse(a.createdAt) ?? DateTime(1970);
                                      final bDate = DateTime.tryParse(b.createdAt) ?? DateTime(1970);
                                      return bDate.compareTo(aDate);
                                    });
                                  final post = sortedPosts[index];
                                  return PostCard(
                                    postId: post.id,
                                    userId: post.userId,
                                    name: post.userName.isNotEmpty ? post.userName : _userModel!.name,
                                    tag: post.title,
                                    timeAgo: _formatTimeAgo(post.createdAt),
                                    content: post.content,
                                    stars: post.likesCount,
                                    comments: post.commentsCount,
                                    showMenu: false,
                                  );
                                },
                                childCount: _userModel!.posts.length,
                                addAutomaticKeepAlives: true,
                                addRepaintBoundaries: true,
                              ),
                            ),
                    ),
                ],
              ),
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
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ENHANCED PROFILE CARD WITH MAP THEME
  Widget _buildOptimizedProfileCard(OtherUserModel user) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Darker glassmorphism effect
        color: const Color(0xFF2A2D5A).withOpacity(0.8),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileHeader(user),
          const SizedBox(height: 12),
          _buildAcademicDetails(user),
          const SizedBox(height: 12),
          _buildActionButtons(user),
        ],
      ),
    );
  }

  // ENHANCED PROFILE HEADER
  Widget _buildProfileHeader(OtherUserModel user) {
    return Row(
      children: [
        Hero(
          tag: 'other_user_profile_image_${user.username}',
          child: GestureDetector(
            onTap: () {
              showProfileImageViewer(
                context,
                imageUrl: user.image_url,
                userName: user.name,
                onEditPressed: null, // No edit for other users
                isEditing: false,
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Enhanced glassmorphism for profile image
                color: Colors.white.withOpacity(0.1),
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipOval(
                child: (user.image_url != null && user.image_url!.startsWith('http'))
                    ? Image.network(
                        user.image_url!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                      )
                    : Image.asset(
                        user.image_url ?? 'lib/core/assets/profile_photo.jpeg',
                        fit: BoxFit.cover,
                        cacheWidth: 200,
                        cacheHeight: 200,
                        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '@${user.username}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
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
          colors: [const Color(0xFF6366F1).withOpacity(0.3), const Color(0xFF8B5CF6).withOpacity(0.3)],
        ),
      ),
      child: Icon(
        Icons.person,
        color: Colors.white.withOpacity(0.8),
        size: 40,
      ),
    );
  }

  // ENHANCED ACADEMIC DETAILS
  Widget _buildAcademicDetails(OtherUserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Expanded(child: _buildDetailColumn('Branch', user.branch)),
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
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ENHANCED ACTION BUTTONS
  Widget _buildActionButtons(OtherUserModel user) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Message',
            Colors.white.withOpacity(0.15),
            Colors.white,
            () => _sendMessage(user),
            icon: Icons.message,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Share',
            Colors.white.withOpacity(0.15),
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
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D3A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: 18),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF3A3E7A).withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 25,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.orange),
              title: const Text('Report', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _reportUser();
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _blockUser();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _sendMessage(OtherUserModel user) {
    HapticFeedback.mediumImpact();
    // Navigate to chat/message screen
    // You'll need to implement this navigation
    ProfileDialogs.showSnackBar(context, 'Message feature coming soon!');
  }

  void _shareProfile() async {
    HapticFeedback.mediumImpact();
    ProfileDialogs.showSnackBar(context, 'Share feature coming soon!');
  }

  void _reportUser() {
    HapticFeedback.mediumImpact();
    ProfileDialogs.showSnackBar(context, 'Report feature coming soon!');
  }

  void _blockUser() {
    HapticFeedback.mediumImpact();
    ProfileDialogs.showSnackBar(context, 'Block feature coming soon!');
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

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
} 