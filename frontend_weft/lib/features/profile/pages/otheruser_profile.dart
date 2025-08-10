import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend_weft/features/messages/view/pages/chat_page.dart';
import 'package:frontend_weft/features/messages/viewmodel/conversations_viewmodel.dart';
import 'package:frontend_weft/features/messages/viewmodel/chat_viewmodel.dart';
import 'package:frontend_weft/features/messages/repository/message_repository.dart';
import 'package:frontend_weft/features/post/view/widgets/post_card.dart';
import 'package:frontend_weft/features/profile/models/other_user_model.dart';
import 'package:frontend_weft/features/profile/services/profile_api_service.dart';
import 'package:frontend_weft/features/profile/widgets/profile_dialogs.dart';
import 'package:frontend_weft/features/profile/widgets/profile_image_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherUserProfilePage extends ConsumerStatefulWidget {
  final String Id;

  const OtherUserProfilePage({
    super.key,
    required this.Id,
  });

  @override
  ConsumerState<OtherUserProfilePage> createState() =>
      _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends ConsumerState<OtherUserProfilePage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _profileCardKey = GlobalKey();

  bool _isProfileCardPinned = false;
  double _profileCardHeight = 0;

  late AnimationController _animationController;

  bool _isLoading = false;
  String? _errorMessage;

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

    _fetchUserData();
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profileService = ref.read(profileApiServiceProvider);
      final userData = await profileService.getOtherUserProfile(widget.Id);

      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading profile: $e';
          _isLoading = false;
        });
      }
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
            // --- FIXED: Removed problematic NotificationListener ---
            CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  expandedHeight: 60,
                  backgroundColor: AppPallete.transperantColor,
                  elevation: 0,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  actions: [
                    if (_userModel != null) ...[
                      Consumer(
                        builder: (context, ref, child) {
                          final currentUser = ref.watch(authViewModelProvider);
                          final isOwnProfile =
                              currentUser?.id == _userModel!.id;

                          if (isOwnProfile) {
                            return const SizedBox.shrink();
                          }

return Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.white),
                              onPressed: () => _showOptionsMenu(context),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
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
                                    color: AppPallete.textPrimaryDark
                                        .withValues(alpha: 0.7),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final sortedPosts =
                                    List.of(_userModel!.posts)
                                      ..sort((a, b) {
                                        final aDate =
                                            DateTime.tryParse(a.createdAt) ??
                                                DateTime(1970);
                                        final bDate =
                                            DateTime.tryParse(b.createdAt) ??
                                                DateTime(1970);

return bDate.compareTo(aDate);
                                      });
                                final post = sortedPosts[index];
                                return PostCard(
                                  postId: post.id,
                                  userId: post.userId,
                                  username: post.username.isNotEmpty
                                      ? post.username
                                      : _userModel!.name,
                                  tag: post.title,
                                  timeAgo: _formatTimeAgo(post.createdAt),
                                  content: post.content,
                                  stars: post.likesCount,
                                  comments: post.commentsCount,
                                  showMenu: false,
                                  verified: _userModel!.isVerified,
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
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppPallete.textPrimaryDark),
                  ),
                ),
              ),
            if (_errorMessage != null)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8),
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

  Widget _buildOptimizedProfileCard(OtherUserModel user) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
          const SizedBox(height: 12),
          _buildAcademicDetails(user),
          const SizedBox(height: 12),
          _buildActionButtons(user),
        ],
      ),
    );
  }

Widget _buildProfileHeader(OtherUserModel user) {
    return Row(
      children: [
        Hero(
          tag: 'other_user_profile_image_${user.username}',
          child: GestureDetector(
            onTap: () {
              showProfileImageViewer(
                context,
                imageUrl: user.imageUrl,
                userName: user.name,
                onEditPressed: null,
                isEditing: false,
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
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
                child:
                    (user.imageUrl != null && user.imageUrl!.startsWith('http'))
                        ? Image.network(
                            user.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                          )
                        : Image.asset(
                            user.imageUrl ??
                                'lib/core/assets/profile_photo.jpeg',
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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (user.isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified,
                                color: Color(0xFF10B981),
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '@${user.username}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Skills Icon (view only)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${user.name} has ${user.skills.length} skills'),
                          backgroundColor: const Color(0xFF6366F1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Color(0xFF6366F1),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${user.skills.length}',
                            style: const TextStyle(
                              color: Color(0xFF6366F1),
                              fontSize: 12,
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

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.3),
            const Color(0xFF8B5CF6).withValues(alpha: 0.3)
          ],
        ),
      ),
      child: Icon(
        Icons.person,
        color: Colors.white.withValues(alpha: 0.8),
        size: 40,
      ),
    );
  }

Widget _buildAcademicDetails(OtherUserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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
          Expanded(child: _buildDetailColumn('Joined', user.year)),
          Container(
            width: 1,
            height: 32,
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
            height: 32,
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
          Expanded(child: _buildInstagramColumn(user.instagramId)),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
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

  // INSTAGRAM COLUMN WITH CLICK FUNCTIONALITY (VIEW ONLY)
  Widget _buildInstagramColumn(String? instagramId) {
    return Column(
      children: [
        Text(
          'Instagram',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _openInstagram(instagramId ?? ''),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: instagramId != null && instagramId.isNotEmpty 
                  ? const Color(0xFFE4405F).withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: instagramId != null && instagramId.isNotEmpty 
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
                if (instagramId != null && instagramId.isNotEmpty) ...[
                  const Icon(
                    Icons.camera_alt,
                    color: Color(0xFFE4405F),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    instagramId != null && instagramId.isNotEmpty 
                        ? '@$instagramId'
                        : 'Not set',
                    style: TextStyle(
                      color: instagramId != null && instagramId.isNotEmpty 
                          ? const Color(0xFFE4405F)
                          : Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
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

  // SKILLS SECTION
  Widget _buildActionButtons(OtherUserModel user) {
    return Consumer(
      builder: (context, ref, child) {
        final currentUser = ref.watch(authViewModelProvider);
        final isOwnProfile = currentUser?.id == user.id;

        if (isOwnProfile) {
          // Don't show message button for own profile
          return Row(
            children: [
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

        return Row(
          children: [
            Expanded(
              child: _buildMessageButton(user),
            ),
            const SizedBox(width: 12),
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
      },
    );
  }

  Widget _buildMessageButton(OtherUserModel user) {
    return Consumer(
      builder: (context, ref, child) {
        // Watch socket connection status
        final connectionState = ref.watch(socketConnectionProvider);
        
        return connectionState.when(
          data: (isConnected) => _buildEnhancedMessageButton(
            user,
            isConnected: isConnected,
            isLoading: false,
          ),
          loading: () => _buildEnhancedMessageButton(
            user,
            isConnected: false,
            isLoading: true,
          ),
          error: (_, __) => _buildEnhancedMessageButton(
            user,
            isConnected: false,
            isLoading: false,
            hasError: true,
          ),
        );
      },
    );
  }

  Widget _buildEnhancedMessageButton(
    OtherUserModel user, {
    required bool isConnected,
    required bool isLoading,
    bool hasError = false,
  }) {
    String buttonText = 'Message';
    String tooltipText = '';
    IconData buttonIcon = Icons.message;
    Color? iconColor;
    VoidCallback? onPressed = () => _sendMessage(user);

    if (isLoading) {
      buttonText = 'Connecting...';
      tooltipText = 'Connecting to messaging service...';
      buttonIcon = Icons.sync;
      onPressed = null;
    } else if (hasError) {
      buttonText = 'Message';
      tooltipText = 'Messaging service unavailable. Tap to try anyway.';
      buttonIcon = Icons.message_outlined;
      iconColor = Colors.orange;
    } else if (isConnected) {
      buttonText = 'Message';
      tooltipText = 'Send a message to ${user.name}';
      buttonIcon = Icons.message;
      iconColor = Colors.green;
    } else {
      buttonText = 'Message';
      tooltipText = 'Send a message to ${user.name}';
      buttonIcon = Icons.message_outlined;
    }

    return Tooltip(
      message: tooltipText,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D3A).withValues(alpha: onPressed == null ? 0.4 : 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: onPressed == null ? 0.1 : 0.15),
            width: 1,
          ),
          boxShadow: onPressed == null ? [] : [
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
            borderRadius: BorderRadius.circular(12),
            splashColor: onPressed == null ? null : Colors.white.withValues(alpha: 0.1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    )
                  else
                    Stack(
                      children: [
                        Icon(
                          buttonIcon,
                          color: iconColor ?? Colors.white.withValues(alpha: onPressed == null ? 0.5 : 1.0),
                          size: 18,
                        ),
                        // Small connection indicator dot
                        if (isConnected && !hasError)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: onPressed == null ? 0.5 : 1.0),
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
      ),
    );
  }

Widget _buildActionButton(
    String text,
    Color backgroundColor,
    Color textColor,
    VoidCallback? onPressed, {
    IconData? icon,
  }) {
    final isDisabled = onPressed == null;
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D3A).withValues(alpha: isDisabled ? 0.4 : 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDisabled ? 0.1 : 0.15),
          width: 1,
        ),
        boxShadow: isDisabled ? [] : [
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
          borderRadius: BorderRadius.circular(12),
          splashColor: isDisabled ? null : Colors.white.withValues(alpha: 0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon, 
                    color: textColor.withValues(alpha: isDisabled ? 0.5 : 1.0), 
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: textColor.withValues(alpha: isDisabled ? 0.5 : 1.0),
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

  void _sendMessage(OtherUserModel user) async {
    final currentUser = ref.read(authViewModelProvider);
    if (currentUser == null) {
      ProfileDialogs.showSnackBar(context, 'Please log in to send messages');
      return;
    }

    // Add haptic feedback
    HapticFeedback.lightImpact();

    try {
      final receiverId = int.parse(user.id);
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );

      try {
        // Ensure socket connection is established
        final messageRepo = ref.read(messageRepositoryProvider);
        await messageRepo.connect();
        
        // Create or update conversation in the conversations list
        final newConversation = ConversationSummary(
          userId: receiverId,
          userName: user.name,
          userAvatar: user.imageUrl,
          lastActivity: DateTime.now(),
          isOnline: false, // We don't have online status from profile
        );
        
        // Add conversation to the list
        ref.read(conversationsProvider.notifier).addOrUpdateConversation(newConversation);

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        // Navigate to chat page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatPage(
              receiverId: receiverId,
              receiverName: user.name,
            ),
          ),
        );
      } catch (connectionError) {
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();
        
        print('Connection error: $connectionError');
        ProfileDialogs.showSnackBar(
          context, 
          'Failed to connect to messaging service. Please try again.',
        );
      }
    } catch (e) {
      print('Error parsing user ID: $e');
      ProfileDialogs.showSnackBar(context, 'Error opening chat: Invalid user ID');
    }
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF3A3E7A).withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
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
                color: Colors.white.withValues(alpha: 0.3),
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
      ProfileDialogs.showSnackBar(context, 'Could not open Instagram profile');
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