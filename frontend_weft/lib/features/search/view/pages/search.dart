import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/search/view/pages/wefter_results_page.dart';
import 'package:frontend_weft/features/search/view/pages/skill_based_search_page.dart';
import 'package:frontend_weft/features/search/view/pages/advanced_search_page.dart';
import 'package:frontend_weft/core/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/http_client.dart';
import 'package:frontend_weft/core/utils/responsive_utils.dart';
import 'package:frontend_weft/core/utils/responsive_text_styles.dart';
import 'package:frontend_weft/core/config/responsive_config.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
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
          child: Padding(
            padding: ResponsiveConfig.getContentPadding(context, ContentType.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Search WEFTers',
                  style: ResponsiveTextStyles.getHeading1(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: context.responsiveSpacing(6)),
                Text(
                  'Find anyone by name, username, or @handle',
                  style: ResponsiveTextStyles.getBodyMedium(context).copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                
                SizedBox(height: context.responsiveSpacing(16)),
                
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: context.responsiveBorderRadius(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by name, username, or @handle...',
                      hintStyle: ResponsiveTextStyles.getBodyLarge(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: context.responsiveIconSize(22),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty 
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.white.withValues(alpha: 0.7),
                                size: context.responsiveIconSize(20),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : Container(
                              margin: EdgeInsets.all(context.responsiveSpacing(8)),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1),
                                borderRadius: context.responsiveBorderRadius(12),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.send, 
                                  color: Colors.white, 
                                  size: context.responsiveIconSize(20),
                                ),
                                onPressed: () => _performQuickSearch(),
                              ),
                            ),
                      border: InputBorder.none,
                      contentPadding: context.responsivePadding(horizontal: 20, vertical: 16),
                    ),
                    onChanged: (value) => setState(() {}),
                    onSubmitted: (value) => _performQuickSearch(),
                  ),
                ),
                
                SizedBox(height: context.responsiveSpacing(20)),
                
                // Search Options Grid
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // First Row - Advanced Search & Skills Search
                        _buildResponsiveRow([
                          _buildSearchOptionBox(
                            title: 'Advanced Search',
                            subtitle: 'Search with multiple filters',
                            icon: Icons.tune,
                            color: Color(0xFF6366F1),
                            onTap: () => _navigateToAdvancedSearch(),
                          ),
                          _buildSearchOptionBox(
                            title: 'Skills Search',
                            subtitle: 'Find by technical skills',
                            icon: Icons.code,
                            color: Color(0xFF10B981),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SkillBasedSearchPage(),
                              ),
                            ),
                          ),
                        ]),
                        
                        SizedBox(height: context.isSmallScreen ? 6 : context.responsiveSpacing(8)),
                        
                        // Second Row - Deft & Share Music (Coming Soon)
                        _buildResponsiveRow([
                          _buildComingSoonBox(
                            title: 'D-Weft',
                            subtitle: 'Find your perfect match',
                            icon: Icons.favorite,
                            color: Color(0xFFEF4444),
                          ),
                          _buildComingSoonBox(
                            title: 'Music Share',
                            subtitle: 'Discover music taste',
                            icon: Icons.music_note,
                            color: Color(0xFF8B5CF6),
                          ),
                        ]),
                        
                        SizedBox(height: context.isSmallScreen ? 6 : context.responsiveSpacing(8)),
                        
                        // Third Row - Connect Through Projects & Random Hangout
                        _buildResponsiveRow([
                          _buildComingSoonBox(
                            title: 'Project Connect',
                            subtitle: 'Collaborate on projects',
                            icon: Icons.handshake,
                            color: Color(0xFF06B6D4),
                          ),
                          _buildComingSoonBox(
                            title: 'Hangout Hub',
                            subtitle: 'Random meetups & fun',
                            icon: Icons.group,
                            color: Color(0xFFF59E0B),
                          ),
                        ]),
                        
                        SizedBox(height: context.isSmallScreen ? 8 : context.responsiveSpacing(12)), // Extra bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveRow(List<Widget> children) {
    // Adjust spacing based on screen size to prevent overflow
    final spacing = context.isSmallScreen ? 8.0 : context.responsiveSpacing(12);
    
    if (context.isSmallScreen && context.screenWidth < 340) {
      // For very small screens, use single column to prevent overflow
      return Column(
        children: children
            .asMap()
            .entries
            .map((entry) {
              final isLast = entry.key == children.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
                child: entry.value,
              );
            })
            .toList(),
      );
    } else {
      // Standard two-column layout with constrained spacing
      return Row(
        children: children
            .asMap()
            .entries
            .map((entry) {
              final isLast = entry.key == children.length - 1;
              return [
                Expanded(child: entry.value),
                if (!isLast) SizedBox(width: spacing),
              ];
            })
            .expand((widgets) => widgets)
            .toList(),
      );
    }
  }

  Widget _buildSearchOptionBox({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    // Use a more constrained height that works better on smaller screens
    final cardHeight = context.isSmallScreen ? 140.0 : context.responsiveHeight(155);
    final iconSize = context.responsiveIconSize(24);
    final borderRadius = context.responsiveBorderRadius(20);
    final iconContainerSize = context.isSmallScreen ? 40.0 : context.responsiveWidth(48);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: borderRadius,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: context.responsivePadding(horizontal: 14, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: context.responsiveBorderRadius(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: iconSize,
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: context.isSmallScreen ? 15 : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.responsiveSpacing(3)),
                    Text(
                      subtitle,
                      style: ResponsiveTextStyles.getBodySmall(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: context.isSmallScreen ? 11 : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComingSoonBox({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    // Use a more constrained height that works better on smaller screens
    final cardHeight = context.isSmallScreen ? 140.0 : context.responsiveHeight(155);
    final iconSize = context.responsiveIconSize(24);
    final borderRadius = context.responsiveBorderRadius(20);
    final iconContainerSize = context.isSmallScreen ? 40.0 : context.responsiveWidth(48);
    
    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: borderRadius,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: context.responsivePadding(horizontal: 14, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: context.responsiveBorderRadius(12),
                  ),
                  child: Icon(
                    icon,
                    color: color.withValues(alpha: 0.6),
                    size: iconSize,
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                          fontSize: context.isSmallScreen ? 15 : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: context.responsiveSpacing(3)),
                      Text(
                        subtitle,
                        style: ResponsiveTextStyles.getBodySmall(context).copyWith(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: context.isSmallScreen ? 11 : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: context.responsiveSpacing(12),
            right: context.responsiveSpacing(12),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSpacing(6), 
                vertical: context.responsiveSpacing(3)
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: context.responsiveBorderRadius(8),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Coming Soon',
                style: ResponsiveTextStyles.getCaption(context).copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: context.isSmallScreen ? 9 : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performQuickSearch() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a search term'),
          backgroundColor: Colors.red,
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
              padding: context.responsivePadding(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Color(0xFF2d2d4a),
                borderRadius: context.responsiveBorderRadius(15),
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
                  SizedBox(height: context.responsiveSpacing(16)),
                  Text(
                    'Searching...',
                    style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
                      color: Colors.white,
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
      
      // Remove @ if present for cleaner search
      String cleanQuery = query.startsWith('@') ? query.substring(1) : query;
      
      // Search both name and username simultaneously for broader results
      final result = await UserService.searchUsersByNameOrUsername(
        query: cleanQuery,
        client: appHttpClient,
      );

      // Hide loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      if (result['success']) {
        final users = result['data'] as List<dynamic>? ?? [];
        Navigator.push(
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

  void _navigateToAdvancedSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdvancedSearchPage(),
      ),
    );
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
    _searchController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _yearController.dispose();
    _branchController.dispose();
    super.dispose();
  }
}