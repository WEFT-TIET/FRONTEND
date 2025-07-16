// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/profile/models/user_model.dart';
import 'package:frontend_weft/features/profile/models/weft_model.dart';
import 'package:frontend_weft/features/profile/services/profile_service.dart';
import 'package:frontend_weft/features/profile/widgets/weft_item_widget.dart';
import 'package:frontend_weft/features/profile/widgets/profile_dialogs.dart';
import 'package:frontend_weft/features/profile/widgets/profile_widget_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  bool _isEditing = false;
  bool _isLoading = false;
  
  // Controllers for editable fields
  late TextEditingController _nameController;
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
    _batchController = TextEditingController(text: user.batch);
    _branchController = TextEditingController(text: user.branch);
    _classController = TextEditingController(text: user.className);
  }

  @override
  Widget build(BuildContext context) {
    final user = _profileService.currentUser;
    final wefts = _profileService.userWefts;

    return Container(
      decoration: BoxDecoration(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Scaffold(
            backgroundColor: AppPallete.transperantColor,
            appBar: AppBar(
              backgroundColor: AppPallete.transperantColor,
              title: Text(
                'WEFT',
                style: TextStyle(
                  color: AppPallete.textPrimaryDark,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/settings');
                  },
                ),
              ],
            ),
            body: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppPallete.profileAccent),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        // Profile Card
                        ProfileCardWidget(
                          user: user,
                          isEditing: _isEditing,
                          nameController: _nameController,
                          batchController: _batchController,
                          branchController: _branchController,
                          classController: _classController,
                          onToggleEdit: _toggleEdit,
                          onShareProfile: _shareProfile,
                          onImageTap: _showImagePicker,
                          onRemoveSociety: _removeSociety,
                          onAddSociety: _showAddSocietyDialog,
                        ),
                        const SizedBox(height: 40),
                        
                        // Your Wefts Section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Your Wefs',
                            style: TextStyle(
                              color: AppPallete.textPrimaryDark,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Weft Items
                        ...wefts.map((weft) => WeftItemWidget(
                          weft: weft,
                          onLike: () => _likeWeft(weft.id),
                          onComment: () => _commentWeft(weft.id),
                        )),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _toggleEdit() async {
    if (_isEditing) {
      // Save changes
      setState(() {
        _isLoading = true;
      });
      
      try {
        final updatedUser = _profileService.currentUser.copyWith(
          name: _nameController.text,
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
          _isLoading = false;
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
    setState(() {
      _isLoading = true;
    });
    
    try {
      final message = await _profileService.shareProfile();
      ProfileDialogs.showSnackBar(context, message);
    } catch (e) {
      ProfileDialogs.showSnackBar(context, 'Error sharing profile');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImagePicker() {
    ProfileDialogs.showImagePicker(context);
  }

  void _showAddSocietyDialog() {
    ProfileDialogs.showAddSocietyDialog(
      context,
      (societyName) async {
        setState(() {
          _isLoading = true;
        });
        
        try {
          await _profileService.addSociety(societyName);
          setState(() {});
          ProfileDialogs.showSnackBar(context, 'Society added successfully!');
        } catch (e) {
          ProfileDialogs.showSnackBar(context, 'Error adding society');
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  void _removeSociety(String society) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _profileService.removeSociety(society);
      setState(() {});
      ProfileDialogs.showSnackBar(context, 'Society removed successfully!');
    } catch (e) {
      ProfileDialogs.showSnackBar(context, 'Error removing society');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
    _batchController.dispose();
    _branchController.dispose();
    _classController.dispose();
    super.dispose();
  }
}