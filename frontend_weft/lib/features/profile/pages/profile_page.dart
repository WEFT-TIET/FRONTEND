import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/post/view/pages/create_post_page.dart';
import 'package:frontend_weft/features/profile/models/user_model.dart';
import 'package:frontend_weft/features/profile/services/profile_api_service.dart';
import 'package:frontend_weft/features/profile/widgets/profile_dialogs.dart';
import 'package:frontend_weft/features/profile/widgets/profile_image_viewer.dart';
import 'package:frontend_weft/features/post/view/widgets/post_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

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
  bool _isEditing = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _yearController;
  late TextEditingController _branchController;

  // Add your Cloudinary details here
  static const String _cloudName = 'CLOUDINARY_CLOUD_NAME';
  static const String _uploadPreset = 'CLOUDINARY_UPLOAD_PRESET';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllersWithDefaults();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    });
  }

  void _initializeControllersWithDefaults([UserModel? user]) {
    // Use empty strings as default if user is null
    _nameController = TextEditingController(text: user?.name ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _yearController = TextEditingController(text: user?.year ?? '');
    _branchController = TextEditingController(text: user?.branch ?? '');
  }

  void _updateControllers(UserModel user) {
    _nameController.text = user.name;
    _usernameController.text = user.username;
    _yearController.text = user.year;
    _branchController.text = user.branch;
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
        body: userProfileAsync.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text('No profile data found'));
            }
            _updateControllers(user);
            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // Profile Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: RepaintBoundary(
                          child: _buildOptimizedProfileCard(user),
                        ),
                      ),
                    ),
                    
                    // Section Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: RepaintBoundary(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Your Wefs',
                                style: TextStyle(
                                  color: AppPallete.textPrimaryDark,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add, color: AppPallete.textPrimaryDark),
                                    tooltip: 'Create Weft',
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const CreatePostPage(),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh, color: AppPallete.textPrimaryDark),
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
                              padding: const EdgeInsets.only(top: 32.0),
                              child: RepaintBoundary(
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
                                      showMenu: false,
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
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 80),
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

  // ENHANCED PROFILE CARD WITH MAP THEME
  Widget _buildOptimizedProfileCard(UserModel user) {
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
          _buildAcademicDetails(),
          const SizedBox(height: 12),
          _buildActionButtons(user),
        ],
      ),
    );
  }

  // ENHANCED PROFILE HEADER
  Widget _buildProfileHeader(UserModel user) {
    return Row(
      children: [
        Hero(
          tag: 'profile_image',
          child: GestureDetector(
            onTap: () {
              if (_isEditing) {
                _showImagePicker(user);
              } else {
                showProfileImageViewer(
                  context,
                  imageUrl: user.image_url,
                  userName: user.name,
                  onEditPressed: () => _showImagePicker(user),
                  isEditing: false,
                );
              }
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Enhanced glassmorphism for profile image
                color: Colors.white.withOpacity(0.1),
                border: _isEditing
                    ? Border.all(color: const Color(0xFF6366F1), width: 3)
                    : Border.all(color: Colors.white.withOpacity(0.4), width: 2),
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
                child: _isEditing
                    ? Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt, 
                          color: Colors.white, 
                          size: 32
                        ),
                      )
                    : (user.image_url != null && user.image_url!.startsWith('http'))
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isEditing
                    ? _buildEditableField(_nameController, 24, FontWeight.bold)
                    : Text(
                        user.name,
                        key: const ValueKey('name_text'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isEditing
                    ? _buildEditableField(_usernameController, 16, FontWeight.w500, prefix: '@')
                    : Text(
                        '@${user.username}',
                        key: const ValueKey('username_text'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
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

  // ENHANCED EDITABLE FIELD
  Widget _buildEditableField(
    TextEditingController controller,
    double fontSize,
    FontWeight fontWeight, {
    String? prefix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D3A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        decoration: InputDecoration(
          isDense: true,
          prefixText: prefix,
          prefixStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  // ENHANCED ACADEMIC DETAILS
  Widget _buildAcademicDetails() {
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
          Expanded(child: _buildDetailColumn('Year', _yearController)),
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
          Expanded(child: _buildDetailColumn('Branch', _branchController)),
        ],
      ),
    );
  }

  // ENHANCED DETAIL COLUMN
  Widget _buildDetailColumn(String title, TextEditingController controller) {
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isEditing
              ? SizedBox(
                  width: title == 'Branch' ? 100 : 60,
                  child: _buildEditableField(controller, 16, FontWeight.w600),
                )
              : Text(
                  controller.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ],
    );
  }

  // ENHANCED ACTION BUTTONS
  Widget _buildActionButtons(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            _isEditing ? 'Save' : 'Edit',
            Colors.white.withOpacity(0.15),
            Colors.white,
            () => _toggleEdit(user),
            icon: _isEditing ? Icons.save : Icons.edit,
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
          year: _yearController.text,
          branch: _branchController.text,
        );
        final api = ref.read(profileApiServiceProvider);
        final success = await api.updateUserProfile(updatedUser.toJson());
        if (success) {
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
        CloudinaryFile.fromFile(
          filePath,
          resourceType: CloudinaryResourceType.Image,
          publicId: 'profile_pictures/user_${user.username}',
        ),
      );
      final image_url = response.secureUrl;
      final api = ref.read(profileApiServiceProvider);
      final updatedUser = user.copyWith(image_url: image_url);
      final success = await api.updateUserProfile(updatedUser.toJson());
      if (success) {
        ref.invalidate(userProfileProvider);
        ProfileDialogs.showSnackBar(context, 'Profile image updated!');
      } else {
        setState(() => _errorMessage = 'Failed to update profile image');
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
    _nameController.dispose();
    _usernameController.dispose();
    _yearController.dispose();
    _branchController.dispose();
    super.dispose();
  }
}