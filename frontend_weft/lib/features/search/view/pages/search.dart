import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Society> popularSocieties = [
    Society(
      name: 'CCS',
      icon: Icons.computer,
      memberCount: '2.4k members',
      isHot: true,
    ),
    Society(
      name: 'FAPS',
      icon: Icons.flag,
      memberCount: '1.8k members',
      isHot: false,
    ),
    Society(
      name: 'DRAMA',
      icon: Icons.theater_comedy,
      memberCount: '1.2k members',
      isHot: true,
    ),
    Society(
      name: 'MUSIC',
      icon: Icons.music_note,
      memberCount: '3.1k members',
      isHot: false,
    ),
    Society(
      name: 'DANCE',
      icon: Icons.accessibility_new,
      memberCount: '2.7k members',
      isHot: false,
    ),
    Society(
      name: 'DEBATE',
      icon: Icons.forum,
      memberCount: '1.5k members',
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
                              print(
                                'Tapped on ${popularSocieties[index].name}',
                              );
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

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Color(0xFF1a1a2e),
        border: Border(top: BorderSide(color: Color(0xFF2d2d4a), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_outlined, 'Home'),
          _buildNavItem(1, Icons.search, 'Search'),
          _buildNavItem(2, Icons.chat_bubble_outline, 'Messages'),
          _buildNavItem(3, Icons.person_outline, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Color(0xFF6366f1) : Colors.grey[400],
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Color(0xFF6366f1) : Colors.grey[400],
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WEFTer Page Class
class WEFTerPage extends StatefulWidget {
  const WEFTerPage({super.key});

  @override
  _WEFTerPageState createState() => _WEFTerPageState();
}

class _WEFTerPageState extends State<WEFTerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();

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
                              controller: _batchController,
                              label: 'Batch',
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

  void _findWEFTer() {
    String name = _nameController.text;
    String batch = _batchController.text;
    String branch = _branchController.text;

    print('Searching for WEFTer:');
    print('Name: $name');
    print('Batch: $batch');
    print('Branch: $branch');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for WEFTer...'),
        backgroundColor: Color(0xFF6366f1),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _batchController.dispose();
    _branchController.dispose();
    super.dispose();
  }
}
