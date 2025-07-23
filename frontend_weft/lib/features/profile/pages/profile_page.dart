import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/profile/models/user_model.dart';
import 'package:frontend_weft/features/profile/services/profile_api_service.dart';
import 'package:frontend_weft/features/profile/widgets/weft_item_widget.dart';
import 'package:frontend_weft/features/profile/widgets/profile_dialogs.dart';
import 'package:frontend_weft/features/post/view/widgets/post_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final api = ref.read(profileApiServiceProvider);
  return await api.getUserProfile();
});

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _profileCardKey = GlobalKey();

  bool _isEditing = false;
  bool _isProfileCardPinned = false;
  double _profileCardHeight = 0;

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _batchController;
  late TextEditingController _branchController;
  late TextEditingController _classController;

  // Animation controller for smooth transitions
  late AnimationController _animationController;

  bool _isLoading = false;
  String? _errorMessage;

  // Add your Cloudinary details here
  static const String _cloudName = 'durjlrhaz';
  static const String _uploadPreset = 'ml_default';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllersWithDefaults();
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
  }

  void _initializeControllersWithDefaults([UserModel? user]) {
    // Use empty strings as default if user is null
    _nameController = TextEditingController(text: user?.name ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _batchController = TextEditingController(text: user?.batch ?? '');
    _branchController = TextEditingController(text: user?.branch ?? '');
    _classController = TextEditingController(text: user?.className ?? '');
  }

  void _updateControllers(UserModel user) {
    _nameController.text = user.name;
    _usernameController.text = user.username;
    _batchController.text = user.batch;
    _branchController.text = user.branch;
    _classController.text = user.className;
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
        body: userProfileAsync.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text('No profile data found'));
            }
            _updateControllers(user);
            return Stack(
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
                      SliverAppBar(
                        floating: false,
                        pinned: true,
                        expandedHeight: 60,
                        backgroundColor: AppPallete.transperantColor,
                        elevation: 0,
                        title: const Text(
                          'WEFT',
                          style: TextStyle(
                            color: AppPallete.textPrimaryDark,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        centerTitle: true,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.settings, color: AppPallete.textPrimaryDark),
                            onPressed: () => Navigator.of(context).pushNamed('/settings'),
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: RepaintBoundary(
                            key: _profileCardKey,
                            child: _buildOptimizedProfileCard(user),
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          minHeight: 60,
                          maxHeight: 60,
                          child: Container(
                            color: AppPallete.transperantColor,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Your Wefts',
                                  style: TextStyle(
                                    color: AppPallete.textPrimaryDark,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh, color: AppPallete.textPrimaryDark),
                                  tooltip: 'Refresh',
                                  onPressed: () {
                                    setState(() => _isLoading = true);
                                    ref.invalidate(userProfileProvider);
                                    // Optionally, you can wait for the provider to reload and then set _isLoading = false
                                    Future.delayed(const Duration(milliseconds: 800), () {
                                      if (mounted) setState(() => _isLoading = false);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // TODO: Replace with backend wefts/posts fetching
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        sliver: user.posts.isEmpty
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
                                    final sortedPosts = List.of(user.posts)
                                      ..sort((a, b) {
                                        final aDate = DateTime.tryParse(a.createdAt) ?? DateTime(1970);
                                        final bDate = DateTime.tryParse(b.createdAt) ?? DateTime(1970);
                                        return bDate.compareTo(aDate);
                                      });
                                    final post = sortedPosts[index];
                                    return PostCard(
                                      postId: post.id,
                                      name: post.userName.isNotEmpty ? post.userName : user.name,
                                      tag: post.title,
                                      timeAgo: _formatTimeAgo(post.createdAt),
                                      content: post.content,
                                      stars: post.likesCount,
                                      comments: post.commentsCount,
                                      showMenu: false,
                                    );
                                  },
                                  childCount: user.posts.length,
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
                      color: Colors.red.withOpacity(0.8),
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

  Widget _buildOptimizedProfileCard(UserModel user) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppPallete.cardColorDark.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileHeader(user),
          const SizedBox(height: 16),
          _buildAcademicDetails(),
          const SizedBox(height: 16),
          _buildActionButtons(user),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Row(
      children: [
        Hero(
          tag: 'profile_image',
          child: GestureDetector(
            onTap: _isEditing ? () => _showImagePicker(user) : null,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPallete.cardColorDark.withOpacity(0.4),
                border: _isEditing
                    ? Border.all(color: AppPallete.textPrimaryDark, width: 2)
                    : Border.all(color: AppPallete.textPrimaryDark.withOpacity(0.3)),
              ),
              child: ClipOval(
                child: _isEditing
                    ? Icon(Icons.camera_alt, color: AppPallete.textPrimaryDark, size: 28)
                    : (user.image_url != null && user.image_url!.startsWith('http'))
                        ? Image.network(
                            user.image_url!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person,
                              color: AppPallete.textPrimaryDark.withOpacity(0.6),
                              size: 35,
                            ),
                          )
                        : Image.asset(
                            user.image_url ?? 'lib/core/assets/profile_photo.jpeg',
                            fit: BoxFit.cover,
                            cacheWidth: 200,
                            cacheHeight: 200,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person,
                              color: AppPallete.textPrimaryDark.withOpacity(0.6),
                              size: 35,
                            ),
                          ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isEditing
                    ? _buildEditableField(_nameController, 22, FontWeight.bold)
                    : Text(
                        user.name,
                        key: const ValueKey('name_text'),
                        style: TextStyle(
                          color: AppPallete.textPrimaryDark,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isEditing
                    ? _buildEditableField(_usernameController, 16, FontWeight.normal, prefix: '@')
                    : Text(
                        '@${user.username}',
                        key: const ValueKey('username_text'),
                        style: TextStyle(
                          color: AppPallete.textPrimaryDark.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(
    TextEditingController controller,
    double fontSize,
    FontWeight fontWeight, {
    String? prefix,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: AppPallete.textPrimaryDark,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      decoration: InputDecoration(
        isDense: true,
        prefixText: prefix,
        prefixStyle: TextStyle(color: AppPallete.textPrimaryDark.withOpacity(0.7)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppPallete.textPrimaryDark.withOpacity(0.3)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppPallete.textPrimaryDark),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
      ),
    );
  }

  Widget _buildAcademicDetails() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppPallete.cardColorDark.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDetailColumn('Batch', _batchController),
          _buildDivider(),
          _buildDetailColumn('Branch', _branchController),
          _buildDivider(),
          _buildDetailColumn('Class', _classController),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String title, TextEditingController controller) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppPallete.textPrimaryDark.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isEditing
              ? SizedBox(
                  width: 60,
                  child: _buildEditableField(controller, 16, FontWeight.w600),
                )
              : Text(
                  controller.text,
                  style: TextStyle(
                    color: AppPallete.textPrimaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppPallete.textPrimaryDark.withOpacity(0.1),
    );
  }

  Widget _buildActionButtons(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            _isEditing ? 'Save' : 'Edit Profile',
            AppPallete.cardColorDark.withOpacity(0.4),
            AppPallete.textPrimaryDark,
            () => _toggleEdit(user),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Share',
            const Color.fromARGB(255, 124, 185, 242).withOpacity(0.8),
            Colors.white,
            _shareProfile,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String text,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.white.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleEdit(UserModel user) async {
    if (_isEditing) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        final updatedUser = user.copyWith(
          name: _nameController.text,
          username: _usernameController.text,
          batch: _batchController.text,
          branch: _branchController.text,
          className: _classController.text,
        );
        final api = ref.read(profileApiServiceProvider);
        final success = await api.updateUserProfile(updatedUser.toJson());
        if (success) {
          // Refresh the user profile provider
          ref.invalidate(userProfileProvider);
          setState(() => _isEditing = false);
          HapticFeedback.lightImpact();
          ProfileDialogs.showSnackBar(context, 'Profile updated!');
        } else {
          setState(() => _errorMessage = 'Update failed');
        }
      } catch (e) {
        setState(() => _errorMessage = 'Update failed: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isEditing = true);
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _shareProfile() async {
    HapticFeedback.mediumImpact();
    // TODO: Implement real share logic or use Share package
    ProfileDialogs.showSnackBar(context, 'Share feature coming soon!');
  }

  void _showImagePicker(UserModel user) async {
    HapticFeedback.selectionClick();
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _uploadProfileImageToCloudinary(pickedFile.path, user);
    }
  }

  Future<void> _uploadProfileImageToCloudinary(String filePath, UserModel user) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(filePath, resourceType: CloudinaryResourceType.Image),
      );
      final image_url = response.secureUrl;
      final api = ref.read(profileApiServiceProvider);
      final backendImageUrl = await api.uploadProfileImage(image_url);
      if (backendImageUrl != null) {
        final updatedUser = user.copyWith(image_url: backendImageUrl);
        final success = await api.updateUserProfile(updatedUser.toJson());
        if (success) {
          ref.invalidate(userProfileProvider);
          ProfileDialogs.showSnackBar(context, 'Profile image updated!');
        } else {
          setState(() => _errorMessage = 'Failed to update profile image');
        }
      } else {
        setState(() => _errorMessage = 'Failed to upload image to backend');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Image upload failed: $e');
    } finally {
      setState(() => _isLoading = false);
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

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _batchController.dispose();
    _branchController.dispose();
    _classController.dispose();
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