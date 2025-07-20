// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/profile/models/user_model.dart';
import 'package:frontend_weft/features/profile/services/profile_service.dart';
import 'package:frontend_weft/features/profile/widgets/weft_item_widget.dart';
import 'package:frontend_weft/features/profile/widgets/profile_dialogs.dart';
import 'dart:ui'; // Added for BackdropFilter

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  bool _isEditing = false;
  
  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _batchController;
  late TextEditingController _branchController;
  late TextEditingController _classController;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
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
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppPallete.transperantColor,
          appBar: _buildAppBar(),
          body: _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppPallete.transperantColor,
      elevation: 0,
      title: const Text(
        'WEFT',
        style: TextStyle(
          color: AppPallete.textPrimaryDark,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context).pushNamed('/settings');
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return _profileService.isLoading
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppPallete.profileAccent),
            ),
          )
        : CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Compact Profile Card
                      _buildCompactProfileCard(),
                      const SizedBox(height: 24),
                      
                      // Your Wefts Section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Your Wefts',
                          style: TextStyle(
                            color: AppPallete.textPrimaryDark,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              
              // Optimized Weft List with better performance
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList.builder(
                  itemCount: _profileService.userWefts.length,
                  itemBuilder: (context, index) {
                    final weft = _profileService.userWefts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: WeftItemWidget(
                        key: ValueKey('weft_${weft.id}'), // Better key for performance
                        weft: weft,
                        onLike: () => _likeWeft(weft.id),
                        onComment: () => _commentWeft(weft.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }

  Widget _buildCompactProfileCard() {
    final user = _profileService.currentUser;
    
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppPallete.glassWhite10,
              AppPallete.glassWhite05,
            ],
          ),
          border: Border.all(
            color: AppPallete.glassWhite20,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              children: [
                // Profile Image and Basic Info
                _buildProfileHeader(user),
                const SizedBox(height: 16),

                // Academic Details in a compact row
                _buildAcademicDetails(),
                const SizedBox(height: 16),

                // Societies Section
                if (user.societies.isNotEmpty || _isEditing) ...[
                  _buildSocietiesSection(user),
                  const SizedBox(height: 16),
                ],

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Row(
      children: [
        // Profile Image
        GestureDetector(
          onTap: _isEditing ? _showImagePicker : null,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: _isEditing ? Border.all(color: AppPallete.textPrimaryDark, width: 2) : null,
            ),
            child: _isEditing
                ? const Icon(Icons.camera_alt, color: AppPallete.textPrimaryDark, size: 24)
                : ClipOval(
                    child: Image.asset(
                      user.profileImagePath ?? 'lib/core/assets/profile_photo.jpeg',
                      fit: BoxFit.cover,
                      width: 70,
                      height: 70,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppPallete.profileAccent,
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: AppPallete.textPrimaryDark,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Name and Username
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              _isEditing
                  ? TextFormField(
                      controller: _nameController,
                      style: const TextStyle(
                        color: AppPallete.textPrimaryDark,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppPallete.profileTextSecondary),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppPallete.profileAccent),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                      ),
                    )
                  : Text(
                      user.name,
                      style: const TextStyle(
                        color: AppPallete.textPrimaryDark,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              const SizedBox(height: 4),
              
              // Username
              _isEditing
                  ? TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(
                        color: AppPallete.profileTextSecondary,
                        fontSize: 16,
                      ),
                      decoration: const InputDecoration(
                        prefixText: '@',
                        prefixStyle: TextStyle(color: AppPallete.profileTextSecondary),
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppPallete.profileTextSecondary),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppPallete.profileAccent),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                      ),
                    )
                  : Text(
                      '@${user.username}',
                      style: const TextStyle(
                        color: AppPallete.profileTextSecondary,
                        fontSize: 16,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPallete.profileCardBackground.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCompactDetailColumn('Batch', _batchController, _isEditing),
          _buildVerticalDivider(),
          _buildCompactDetailColumn('Branch', _branchController, _isEditing),
          _buildVerticalDivider(),
          _buildCompactDetailColumn('Class', _classController, _isEditing),
        ],
      ),
    );
  }

  Widget _buildSocietiesSection(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Societies',
            style: TextStyle(
              color: AppPallete.textPrimaryDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...user.societies.map((society) => _buildSocietyChip(society)),
            if (_isEditing) _buildAddSocietyButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            _isEditing ? 'Save Changes' : 'Edit Profile',
            AppPallete.profileCardBackground,
            AppPallete.textPrimaryDark,
            _toggleEdit,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Share',
            AppPallete.profileAccent,
            AppPallete.textPrimaryDark,
            _shareProfile,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDetailColumn(String title, TextEditingController controller, bool isEditing) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppPallete.profileTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        isEditing
            ? SizedBox(
                width: 60,
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppPallete.textPrimaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppPallete.profileTextSecondary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppPallete.profileAccent),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 2),
                  ),
                ),
              )
            : Text(
                controller.text,
                style: const TextStyle(
                  color: AppPallete.textPrimaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppPallete.profileTextSecondary.withOpacity(0.3),
    );
  }

  Widget _buildSocietyChip(String society) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppPallete.profileCardBackground,
        borderRadius: BorderRadius.circular(10),
        border: _isEditing ? Border.all(color: AppPallete.red.withOpacity(0.5)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            society,
            style: const TextStyle(
              color: AppPallete.textPrimaryDark,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_isEditing) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _removeSociety(society),
              child: const Icon(
                Icons.close,
                size: 14,
                color: AppPallete.red,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddSocietyButton() {
    return GestureDetector(
      onTap: _showAddSocietyDialog,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppPallete.profileAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.add,
          color: AppPallete.textPrimaryDark,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color backgroundColor, Color textColor, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
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
    );
  }

  void _toggleEdit() async {
    if (_isEditing) {
      // Save changes
      try {
        final updatedUser = _profileService.currentUser.copyWith(
          name: _nameController.text,
          username: _usernameController.text,
          batch: _batchController.text,
          branch: _branchController.text,
          className: _classController.text,
        );
        
        await _profileService.updateUser(updatedUser);
        
        ProfileDialogs.showSnackBar(context, 'Profile updated successfully!');
      } catch (e) {
        ProfileDialogs.showSnackBar(context, 'Error updating profile');
      } finally {
        setState(() {
          _isEditing = false;
        });
      }
    } else {
      // Enter edit mode
      setState(() {
        _isEditing = true;
      });
    }
  }

  void _shareProfile() async {
    try {
      final message = await _profileService.shareProfile();
      ProfileDialogs.showSnackBar(context, message);
    } catch (e) {
      ProfileDialogs.showSnackBar(context, 'Error sharing profile');
    }
  }

  void _showImagePicker() {
    ProfileDialogs.showImagePicker(context);
  }

  void _showAddSocietyDialog() {
    ProfileDialogs.showAddSocietyDialog(
      context,
      (societyName) async {
        try {
          await _profileService.addSociety(societyName);
          setState(() {});
          ProfileDialogs.showSnackBar(context, 'Society added successfully!');
        } catch (e) {
          ProfileDialogs.showSnackBar(context, 'Error adding society');
        }
      },
    );
  }

  void _removeSociety(String society) async {
    try {
      await _profileService.removeSociety(society);
      setState(() {});
      ProfileDialogs.showSnackBar(context, 'Society removed successfully!');
    } catch (e) {
      ProfileDialogs.showSnackBar(context, 'Error removing society');
    }
  }

  void _likeWeft(String weftId) async {
    try {
      await _profileService.likeWeft(weftId);
      setState(() {});
    } catch (e) {
      ProfileDialogs.showSnackBar(context, 'Error liking weft');
    }
  }

  void _commentWeft(String weftId) async {
    try {
      await _profileService.addComment(weftId);
      setState(() {});
    } catch (e) {
      ProfileDialogs.showSnackBar(context, 'Error adding comment');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _batchController.dispose();
    _branchController.dispose();
    _classController.dispose();
    super.dispose();
  }
}