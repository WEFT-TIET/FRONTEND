// lib/widgets/profile_dialogs.dart
import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/profile/models/society_model.dart';
import 'package:frontend_weft/features/profile/services/profile_service.dart';

class ProfileDialogs {
  static void showImagePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPallete.profileDialogBackground,
        title: Text(
          'Change Profile Picture',
          style: TextStyle(color: AppPallete.textPrimaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppPallete.textPrimaryDark),
              title: Text('Camera', style: TextStyle(color: AppPallete.textPrimaryDark)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement camera functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppPallete.textPrimaryDark),
              title: Text('Gallery', style: TextStyle(color: AppPallete.textPrimaryDark)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement gallery functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  static void showAddSocietyDialog(
    BuildContext context,
    Function(String) onAdd,
  ) {
    final ProfileService profileService = ProfileService();
    String? selectedCategory;
    SocietyModel? selectedSociety;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final availableCategories = SocietyData.categories;
          final availableSocieties = selectedCategory != null
              ? profileService.getSocietiesByCategory(selectedCategory!)
              : <SocietyModel>[];

          return AlertDialog(
            backgroundColor: AppPallete.profileDialogBackground,
            title: Text(
              'Add Society',
              style: TextStyle(
                color: AppPallete.textPrimaryDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Dropdown
                  Text(
                    'Select Category:',
                    style: TextStyle(
                      color: AppPallete.textPrimaryDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppPallete.profileTextSecondary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: Text(
                        'Choose a category',
                        style: TextStyle(color: AppPallete.profileTextSecondary),
                      ),
                      dropdownColor: AppPallete.profileDialogBackground,
                      style: TextStyle(color: AppPallete.textPrimaryDark),
                      items: availableCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                          selectedSociety = null; // Reset society selection
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Society Dropdown
                  if (selectedCategory != null) ...[
                    Text(
                      'Select Society:',
                      style: TextStyle(
                        color: AppPallete.textPrimaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppPallete.profileTextSecondary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: availableSocieties.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                'No societies available in this category',
                                style: TextStyle(
                                  color: AppPallete.profileTextSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          : DropdownButton<SocietyModel>(
                              value: selectedSociety,
                              isExpanded: true,
                              underline: const SizedBox(),
                              hint: Text(
                                'Choose a society',
                                style: TextStyle(color: AppPallete.profileTextSecondary),
                              ),
                              dropdownColor: AppPallete.profileDialogBackground,
                              style: TextStyle(color: AppPallete.textPrimaryDark),
                              items: availableSocieties.map((society) {
                                return DropdownMenuItem<SocietyModel>(
                                  value: society,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        society.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppPallete.textPrimaryDark,
                                        ),
                                      ),
                                      if (society.description.isNotEmpty)
                                        Text(
                                          society.description,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppPallete.profileTextSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedSociety = value;
                                });
                              },
                            ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppPallete.profileTextSecondary),
                ),
              ),
              TextButton(
                onPressed: selectedSociety != null
                    ? () {
                        onAdd(selectedSociety!.name);
                        Navigator.pop(context);
                      }
                    : null,
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: selectedSociety != null
                        ? AppPallete.profileAccent
                        : AppPallete.profileTextSecondary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppPallete.profileCardBackground,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}