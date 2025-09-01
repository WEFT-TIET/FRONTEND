import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/search/view/pages/wefter_results_page.dart';
import 'package:frontend_weft/core/services/user_service.dart';
import 'package:frontend_weft/core/http_client.dart';
import 'package:frontend_weft/core/utils/responsive_utils.dart';
import 'package:frontend_weft/core/utils/responsive_text_styles.dart';
import 'package:frontend_weft/core/config/responsive_config.dart';

class AdvancedSearchPage extends ConsumerStatefulWidget {
  const AdvancedSearchPage({super.key});

  @override
  ConsumerState<AdvancedSearchPage> createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends ConsumerState<AdvancedSearchPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: ResponsiveConfig.getContentPadding(context, ContentType.page),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(),
                      
                      SizedBox(height: context.responsiveSpacing(24)),
                      
                      // Search Fields
                      _buildInputField(
                        controller: _nameController,
                        label: 'Name',
                        placeholder: 'Ex: John Doe',
                        icon: Icons.person,
                      ),
                      
                      SizedBox(height: context.responsiveSpacing(16)),
                      
                      _buildInputField(
                        controller: _usernameController,
                        label: 'Username',
                        placeholder: 'Ex: john_doe',
                        icon: Icons.alternate_email,
                      ),
                      
                      SizedBox(height: context.responsiveSpacing(16)),
                      
                      _buildInputField(
                        controller: _yearController,
                        label: 'Year',
                        placeholder: 'Ex: 2023, 2024, 2025',
                        icon: Icons.calendar_today,
                      ),
                      
                      SizedBox(height: context.responsiveSpacing(16)),
                      
                      _buildInputField(
                        controller: _branchController,
                        label: 'Branch',
                        placeholder: 'Ex: COPC, COE, ECE, ENC',
                        icon: Icons.school,
                      ),
                      
                      SizedBox(height: context.responsiveSpacing(32)),
                      
                      // Search Button
                      _buildSearchButton(),
                      
                      SizedBox(height: context.responsiveSpacing(20)), // Bottom padding for safe area
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final buttonSize = context.responsiveWidth(44);
    
    return Container(
      padding: context.responsivePadding(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: context.responsiveBorderRadius(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: context.responsiveIconSize(20),
              ),
            ),
          ),
          
          Expanded(
            child: Center(
              child: Text(
                'Advanced Search',
                style: ResponsiveTextStyles.getHeading2(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          SizedBox(width: buttonSize), // Balance for centered title
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final iconSize = context.responsiveIconSize(24);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: context.responsivePadding(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                borderRadius: context.responsiveBorderRadius(16),
                border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.tune,
                color: Color(0xFF6366F1),
                size: iconSize,
              ),
            ),
            SizedBox(width: context.responsiveSpacing(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Use multiple filters to find specific WEFTers',
                    style: ResponsiveTextStyles.getBodyMedium(context).copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        SizedBox(height: context.responsiveSpacing(16)),
        
        Container(
          padding: context.responsivePadding(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: context.responsiveBorderRadius(16),
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[300],
                size: context.responsiveIconSize(20),
              ),
              SizedBox(width: context.responsiveSpacing(12)),
              Expanded(
                child: Text(
                  'Fill at least one field to search.',
                  style: ResponsiveTextStyles.getBodyMedium(context).copyWith(
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveSpacing(8)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: context.responsiveBorderRadius(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: ResponsiveTextStyles.getBodyLarge(context).copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.6),
                size: context.responsiveIconSize(20),
              ),
              border: InputBorder.none,
              contentPadding: context.responsivePadding(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchButton() {
    final buttonHeight = context.responsiveHeight(56);
    
    return Container(
      width: double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: Color(0xFF6366F1),
        borderRadius: context.responsiveBorderRadius(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: context.responsiveBorderRadius(16),
          onTap: _findWEFTer,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search,
                  color: Colors.white,
                  size: context.responsiveIconSize(24),
                ),
                SizedBox(width: context.responsiveSpacing(12)),
                Text(
                  'Search WEFTers',
                  style: ResponsiveTextStyles.getButton(context).copyWith(
                    color: Colors.white,
                    fontSize: context.responsiveFontSize(18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _findWEFTer() async {
    String name = _nameController.text.trim();
    String username = _usernameController.text.trim();
    String year = _yearController.text.trim();
    String branch = _branchController.text.trim();

    // Validate that at least one field is filled
    if (name.isEmpty && username.isEmpty && year.isEmpty && branch.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter at least one search criteria'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              padding: context.responsivePadding(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: Color(0xFF2d2d4a),
                borderRadius: context.responsiveBorderRadius(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: context.responsiveWidth(24),
                    height: context.responsiveHeight(24),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366f1)),
                    ),
                  ),
                  SizedBox(height: context.responsiveSpacing(20)),
                  Text(
                    'Searching for WEFTers...',
                    style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final appHttpClient = ref.read(httpClientProvider);
      final result = await UserService.searchUsers(
        name: name.isNotEmpty ? name : null,
        username: username.isNotEmpty ? username : null,
        year: year.isNotEmpty ? year : null,
        branch: branch.isNotEmpty ? branch : null,
        client: appHttpClient,
      );

      // Hide loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      if (result['success']) {
        final users = result['data'] as List<dynamic>? ?? [];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WEFTerResultsPage(users: users),
          ),
        );
      } else {
        _showErrorDialog(result['error']);
      }
    } catch (e) {
      // Hide loading dialog
      Navigator.of(context, rootNavigator: true).pop();
      _showErrorDialog('Network error: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2d2d4a),
          shape: RoundedRectangleBorder(
            borderRadius: context.responsiveBorderRadius(20),
          ),
          title: Text(
            'Search Error',
            style: ResponsiveTextStyles.getHeading3(context).copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
              color: Colors.grey[300],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: ResponsiveTextStyles.getButton(context).copyWith(
                  color: Color(0xFF6366f1),
                ),
              ),
            ),
          ],
        );
      },
    );
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
