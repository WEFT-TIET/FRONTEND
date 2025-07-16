// lib/widgets/profile_card_widget.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/profile/models/user_model.dart';

class ProfileCardWidget extends StatelessWidget {
  final UserModel user;
  final bool isEditing;
  final TextEditingController nameController;
  final TextEditingController batchController;
  final TextEditingController branchController;
  final TextEditingController classController;
  final VoidCallback onToggleEdit;
  final VoidCallback onShareProfile;
  final VoidCallback onImageTap;
  final Function(String) onRemoveSociety;
  final VoidCallback onAddSociety;

  const ProfileCardWidget({
    Key? key,
    required this.user,
    required this.isEditing,
    required this.nameController,
    required this.batchController,
    required this.branchController,
    required this.classController,
    required this.onToggleEdit,
    required this.onShareProfile,
    required this.onImageTap,
    required this.onRemoveSociety,
    required this.onAddSociety,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
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
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Profile Header Row
              Row(
                children: [
                  // Profile Image
                  GestureDetector(
                    onTap: isEditing ? onImageTap : null,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isEditing ? Border.all(color: AppPallete.textPrimaryDark, width: 2) : null,
                      ),
                      child: isEditing
                          ? Icon(Icons.camera_alt, color: AppPallete.textPrimaryDark, size: 28)
                          : ClipOval(
                              child: Image.asset(
                                user.profileImagePath ?? 'lib/core/assets/profile_photo.jpeg',
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: AppPallete.profileAccent,
                                  child: Center(
                                    child: Text(
                                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                      style: TextStyle(
                                        color: AppPallete.textPrimaryDark,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Society Tags
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: user.societies.length + (isEditing ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < user.societies.length) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: _buildSocietyChip(user.societies[index]),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: _buildAddSocietyButton(),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name with House
              Align(
                alignment: Alignment.centerLeft,
                child: isEditing
                    ? TextFormField(
                        controller: nameController,
                        style: TextStyle(
                          color: AppPallete.textPrimaryDark,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppPallete.profileTextSecondary),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppPallete.profileAccent),
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              color: AppPallete.textPrimaryDark,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppPallete.profileCardBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user.house,
                              style: TextStyle(
                                color: AppPallete.profileTextSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),

              // Details Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailColumn('Batch', batchController, isEditing),
                  _buildDetailColumn('Branch', branchController, isEditing),
                  _buildDetailColumn('Class', classController, isEditing),
                ],
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildMainButton(
                      isEditing ? 'Save Changes' : 'Edit Profile',
                      AppPallete.profileCardBackground,
                      AppPallete.textPrimaryDark,
                      onToggleEdit,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMainButton(
                      'Share',
                      AppPallete.profileAccent,
                      AppPallete.textPrimaryDark,
                      onShareProfile,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocietyChip(String society) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppPallete.profileCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: isEditing ? Border.all(color: AppPallete.red.withOpacity(0.5)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            society,
            style: TextStyle(
              color: AppPallete.textPrimaryDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isEditing) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onRemoveSociety(society),
              child: Icon(
                Icons.close,
                size: 16,
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
      onTap: onAddSociety,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppPallete.profileAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.add,
          color: AppPallete.textPrimaryDark,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String title, TextEditingController controller, bool isEditing) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppPallete.profileTextSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        isEditing
            ? SizedBox(
                width: 80,
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppPallete.textPrimaryDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppPallete.profileTextSecondary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppPallete.profileAccent),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              )
            : Text(
                controller.text,
                style: TextStyle(
                  color: AppPallete.textPrimaryDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ],
    );
  }

  Widget _buildMainButton(String text, Color backgroundColor, Color textColor, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}