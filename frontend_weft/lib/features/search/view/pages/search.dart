import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/search/view/pages/register_milan.dart';
import 'package:frontend_weft/core/config/api_config.dart';
import 'package:frontend_weft/core/services/user_service.dart';
import 'milan.dart';
//import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/http_client.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Society> popularSocieties = [
    Society(
      name: 'MILAN',
      icon: Icons.people,
      memberCount: '2.4k members',
      isHot: true,
    ),
  ];

  final List<String> recentSearches = ['Tech Fest', 'Drama Workshop'];

  void _navigateToWEFTerPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WEFTerPage()),
    );
  }

  final List<Widget> pages = [
    Milan(),
  ];

  void _navigateToPages(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => pages[index]),
    );
  }

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
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: _navigateToWEFTerPage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF2d2d4a),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Color(0xFF3d3d5a),
                              width: 1,
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.grey[400]),
                                SizedBox(width: 12),
                                Text(
                                  'Search students, societies, events...',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      Text(
                        'Societies',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: popularSocieties.length,
                        itemBuilder: (context, index) {
                          return SocietyCard(
                            society: popularSocieties[index],
                            onTap: () {
                              _navigateToPages(index);
                            },
                          );
                        },
                      ),
                      SizedBox(height: 32),
                      Text(
                        'Recent Searches',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      ...recentSearches.map(
                        (search) => RecentSearchItem(
                          searchText: search,
                          onTap: () {
                            _navigateToWEFTerPage();
                          },
                        ),
                      ),
                      SizedBox(height: 100),
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
}

class Society {
  final String name;
  final IconData icon;
  final String memberCount;
  final bool isHot;

  Society({
    required this.name,
    required this.icon,
    required this.memberCount,
    required this.isHot,
  });
}

class SocietyCard extends StatelessWidget {
  final Society society;
  final VoidCallback onTap;

  const SocietyCard({super.key, required this.society, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppPallete.glassWhite05,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppPallete.glassWhite20, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Container
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF6366f1).withOpacity(0.4),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(society.icon, color: Colors.white, size: 28),
                  ),

                  SizedBox(height: 16),

                  // Society Name
                  Text(
                    society.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  // Member Count
                  Text(
                    society.memberCount,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),

            // Hot Badge
            if (society.isHot)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFf97316), Color(0xFFea580c)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'HOT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RecentSearchItem extends StatelessWidget {
  final String searchText;
  final VoidCallback onTap;

  const RecentSearchItem({
    super.key,
    required this.searchText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[400], size: 20),
            SizedBox(width: 16),
            Text(
              searchText,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}



// WEFTer Page Class
class WEFTerPage extends ConsumerStatefulWidget {
  const WEFTerPage({super.key});

  @override
  ConsumerState<WEFTerPage> createState() => _WEFTerPageState();
}

class _WEFTerPageState extends ConsumerState<WEFTerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();  // Changed from batch to year
  final TextEditingController _branchController = TextEditingController();

  // Add a GlobalKey for the widget to access context for Riverpod
  final _wefterPageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _wefterPageKey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f1419)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar with back button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'WEFT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        color: Color(0xFF2d2d4a),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Color(0xFF3d3d5a), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Who\'s the WEFTer?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 8),

                            Text(
                              'Enter the details below to find your WEFTer.',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 32),

                            _buildInputField(
                              controller: _nameController,
                              label: 'Name',
                              placeholder: 'Ex: Rudra Yadav',
                            ),

                            SizedBox(height: 20),

                            _buildInputField(
                              controller: _yearController,
                              label: 'Year',  // Changed from Batch to Year
                              placeholder: 'Grad year? Left for your people!',
                            ),

                            SizedBox(height: 20),

                            _buildInputField(
                              controller: _branchController,
                              label: 'Branch',
                              placeholder: 'Ex: COE, COPC, ENC',
                            ),

                            SizedBox(height: 32),

                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF6366f1),
                                    Color(0xFF8b5cf6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF6366f1).withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: () {
                                    _findWEFTer();
                                  },
                                  child: Center(
                                    child: Text(
                                      'Find the WEFTer',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF3d3d5a),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF4d4d6a), width: 1),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _findWEFTer() async {
    String name = _nameController.text.trim();
    String year = _yearController.text.trim();  
    String branch = _branchController.text.trim();

    // Validate that at least one field is filled
    if (name.isEmpty && year.isEmpty && branch.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter at least one search criteria'),
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
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF2d2d4a),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366f1)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Searching for WEFTer...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Use AppHttpClient from provider
      final appHttpClient = ref.read(httpClientProvider);
      final result = await UserService.searchUsers(
        name: name.isNotEmpty ? name : null,
        year: year.isNotEmpty ? year : null,
        branch: branch.isNotEmpty ? branch : null,
        client: appHttpClient,
      );

      print('🤣Raw API response: $result');

      // Hide loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      if (result['success']) {
        final users = result['data'] as List<dynamic>? ?? [];
        if (users.isEmpty) {
          _showNoResultsDialog();
        } else {
          _showSearchResults(users);
        }
      } else {
        _showErrorDialog(result['error']);
      }
    } catch (e) {
      // Hide loading dialog
      Navigator.of(context, rootNavigator: true).pop();
      _showErrorDialog('Network error: $e');
    }
  }

  void _showNoResultsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2d2d4a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'No WEFTers Found',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'No users found matching your search criteria. Try different keywords or check your spelling.',
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(color: Color(0xFF6366f1)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2d2d4a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Search Error',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(color: Color(0xFF6366f1)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSearchResults(List<dynamic> users) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WEFTerResultsPage(users: users),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    _branchController.dispose();
    super.dispose();
  }
}

// WEFTer Results Page
class WEFTerResultsPage extends StatelessWidget {
  final List<dynamic> users;

  const WEFTerResultsPage({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f1419)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Search Results (${users.length})',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),

              // Results List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return WEFTerCard(user: user);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// WEFTer Card Widget
class WEFTerCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const WEFTerCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFF2d2d4a),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF3d3d5a), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
                              // Profile Image (Default avatar coz no profile_photo_url in schema)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF6366f1), width: 2),
                    ),
                    child: Container(
                      color: Color(0xFF3d3d5a),
                      child: Icon(
                        Icons.person,
                        color: Colors.grey[400],
                        size: 30,
                      ),
                    ),
                  ),

            SizedBox(width: 16),

            // User Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  if (user['year'] != null)
                    Text(
                      'Year: ${user['year']}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  if (user['branch'] != null)
                    Text(
                      'Branch: ${user['branch']}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  if (user['class_id'] != null)
                    Text(
                      'Class: ${user['class_id']}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),

            // Action Button
            IconButton(
              onPressed: () {
                _showUserProfile(context, user);
              },
              icon: Icon(
                Icons.visibility,
                color: Color(0xFF6366f1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserProfile(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Color(0xFF2d2d4a),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFF3d3d5a), width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile Image (Default avatar since no profile_photo_url in schema)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF6366f1), width: 3),
                    ),
                    child: Container(
                      color: Color(0xFF3d3d5a),
                      child: Icon(
                        Icons.person,
                        color: Colors.grey[400],
                        size: 50,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // User Name
                  Text(
                    user['name'] ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 16),

                  // User Details
                  _buildDetailRow('Year', user['year'] ?? 'Not specified'),
                  _buildDetailRow('Branch', user['branch'] ?? 'Not specified'),
                  _buildDetailRow('Class', user['class_id'] ?? 'Not specified'),
                  _buildDetailRow('Email', user['email'] ?? 'Not specified'),

                  SizedBox(height: 24),

                  // Close Button
                  Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () => Navigator.of(context).pop(),
                        child: Center(
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
