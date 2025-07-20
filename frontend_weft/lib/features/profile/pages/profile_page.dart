import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/profile/models/user_model.dart';
import 'package:frontend_weft/features/profile/services/profile_service.dart';
import 'package:frontend_weft/features/profile/widgets/weft_item_widget.dart';
import 'package:frontend_weft/features/profile/widgets/profile_dialogs.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> 
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
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
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
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

  void _initializeControllers() {
    final user = _profileService.currentUser;
    _nameController = TextEditingController(text: user.name);
    _usernameController = TextEditingController(text: user.username);
    _batchController = TextEditingController(text: user.batch);
    _branchController = TextEditingController(text: user.branch);
    _classController = TextEditingController(text: user.className);
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
                        child: _buildOptimizedProfileCard(),
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
                        child: const Text(
                          'Your Wefts',
                          style: TextStyle(
                            color: AppPallete.textPrimaryDark,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= _profileService.userWefts.length) {
                            return const SizedBox(height: 100);
                          }
                          
                          final weft = _profileService.userWefts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RepaintBoundary(
                              child: WeftItemWidget(
                                key: ValueKey('weft_${weft.id}'),
                                weft: weft,
                                onLike: () => _likeWeft(weft.id),
                                onComment: () => _commentWeft(weft.id),
                              ),
                            ),
                          );
                        },
                        childCount: _profileService.userWefts.length + 1,
                        addAutomaticKeepAlives: true,
                        addRepaintBoundaries: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            if (_profileService.isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppPallete.textPrimaryDark),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizedProfileCard() {
    final user = _profileService.currentUser;
    
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
          _buildActionButtons(),
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
            onTap: _isEditing ? _showImagePicker : null,
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
                  : Image.asset(
                      user.profileImagePath ?? 'lib/core/assets/profile_photo.jpeg',
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            _isEditing ? 'Save' : 'Edit Profile',
            AppPallete.cardColorDark.withOpacity(0.4),
            AppPallete.textPrimaryDark,
            _toggleEdit,
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

  void _toggleEdit() async {
    if (_isEditing) {
      try {
        final updatedUser = _profileService.currentUser.copyWith(
          name: _nameController.text,
          username: _usernameController.text,
          batch: _batchController.text,
          branch: _branchController.text,
          className: _classController.text,
        );
        
        await _profileService.updateUser(updatedUser);
        
        if (mounted) {
          setState(() => _isEditing = false);
          HapticFeedback.lightImpact();
          ProfileDialogs.showSnackBar(context, 'Profile updated!');
        }
      } catch (e) {
        if (mounted) {
          ProfileDialogs.showSnackBar(context, 'Update failed');
        }
      }
    } else {
      setState(() => _isEditing = true);
      HapticFeedback.selectionClick();
    }
  }

  void _shareProfile() async {
    HapticFeedback.mediumImpact();
    try {
      final message = await _profileService.shareProfile();
      if (mounted) {
        ProfileDialogs.showSnackBar(context, message);
      }
    } catch (e) {
      if (mounted) {
        ProfileDialogs.showSnackBar(context, 'Share failed');
      }
    }
  }

  void _showImagePicker() {
    HapticFeedback.selectionClick();
    ProfileDialogs.showImagePicker(context);
  }

  void _likeWeft(String weftId) async {
    HapticFeedback.lightImpact();
    try {
      await _profileService.likeWeft(weftId);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  void _commentWeft(String weftId) async {
    HapticFeedback.selectionClick();
    try {
      await _profileService.addComment(weftId);
      if (mounted) setState(() {});
    } catch (_) {}
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