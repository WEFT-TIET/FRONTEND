import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  
  // Controllers for editable fields
  final TextEditingController _nameController = TextEditingController(text: 'Rudra Yadav');
  final TextEditingController _batchController = TextEditingController(text: '2025');
  final TextEditingController _branchController = TextEditingController(text: 'COE');
  final TextEditingController _classController = TextEditingController(text: '1A62');
  
  // Society memberships
  List<String> _societies = ['MLSC', 'CCS'];
  final TextEditingController _societyController = TextEditingController();
  
  // Sample weft data
  final List<Map<String, dynamic>> _wefts = [
    {
      'date': '20/07/15',
      'time': '3:16 AM',
      'content': 'What is Weft?',
      'likes': 12,
      'comments': 5,
    },
    {
      'date': '19/07/15',
      'time': '11:32 PM',
      'content': 'Just finished my Flutter project! 🚀',
      'likes': 8,
      'comments': 3,
    },
    {
      'date': '18/07/15',
      'time': '2:45 PM',
      'content': 'Great workshop on AI today!',
      'likes': 15,
      'comments': 7,
    },
    {
      'date': '17/07/15',
      'time': '10:30 AM',
      'content': 'Looking forward to the hackathon',
      'likes': 6,
      'comments': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
            ],),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  // Profile Card with Glass Effect
                  Container(
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
                                  onTap: _isEditing ? _showImagePicker : null,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: _isEditing ? Border.all(color: AppPallete.textPrimaryDark, width: 2) : null,
                                    ),
                                    child: _isEditing
                                        ? Icon(Icons.camera_alt, color: AppPallete.textPrimaryDark, size: 28)
                                        : ClipOval(
                                            child: Image.asset(
                                              'lib/core/assets/profile_photo.jpeg',
                                              fit: BoxFit.cover,
                                              width: 80,
                                              height: 80,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: AppPallete.profileAccent,
                                                child: Center(
                                                  child: Text(
                                                    'Img',
                                                    style: TextStyle(
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
                                const SizedBox(width: 24),
                                // Society Tags with Horizontal Scrolling
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _societies.length + (_isEditing ? 1 : 0),
                                      itemBuilder: (context, index) {
                                        if (index < _societies.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: _buildSocietyChip(_societies[index]),
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
                  
                            // Name with House (Editable)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _isEditing
                                  ? TextFormField(
                                      controller: _nameController,
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
                                          _nameController.text,
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
                                            'House',
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
                                _buildDetailColumn('Batch', _batchController, _isEditing),
                                _buildDetailColumn('Branch', _branchController, _isEditing),
                                _buildDetailColumn('Class', _classController, _isEditing),
                              ],
                            ),
                            const SizedBox(height: 24),
                  
                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMainButton(
                                    _isEditing ? 'Save Changes' : 'Edit Profile',
                                    AppPallete.profileCardBackground,
                                    AppPallete.textPrimaryDark,
                                    _toggleEdit,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildMainButton(
                                    'Share',
                                    AppPallete.profileAccent,
                                    AppPallete.textPrimaryDark,
                                    _shareProfile,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ), 
                    ),
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
                  ..._wefts.map((weft) => _buildWeftItem(
                        weft['date'],
                        weft['time'],
                        weft['content'],
                        weft['likes'],
                        weft['comments'],
                      )),
                ],
              ),
            ),
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
        border: _isEditing ? Border.all(color: AppPallete.red.withOpacity(0.5)) : null,
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
          if (_isEditing) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _removeSociety(society),
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
      onTap: _showAddSocietyDialog,
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

  Widget _buildWeftItem(String date, String time, String content, int likes, int comments) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Time Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        color: AppPallete.profileTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: AppPallete.profileTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: TextStyle(
                    color: AppPallete.textPrimaryDark,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                // Interaction Buttons
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppPallete.profileCardBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: AppPallete.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            likes.toString(),
                            style: TextStyle(
                              color: AppPallete.textPrimaryDark,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppPallete.profileCardBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            color: AppPallete.textPrimaryDark,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            comments.toString(),
                            style: TextStyle(
                              color: AppPallete.textPrimaryDark,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    });
  }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile shared!')),
    );
  }

  void _showImagePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPallete.profileDialogBackground,
        title: Text('Change Profile Picture', style: TextStyle(color: AppPallete.textPrimaryDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppPallete.textPrimaryDark),
              title: Text('Camera', style: TextStyle(color: AppPallete.textPrimaryDark)),
              onTap: () {
                Navigator.pop(context);
                // Implement camera functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppPallete.textPrimaryDark),
              title: Text('Gallery', style: TextStyle(color: AppPallete.textPrimaryDark)),
              onTap: () {
                Navigator.pop(context);
                // Implement gallery functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSocietyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPallete.profileDialogBackground,
        title: Text('Add Society', style: TextStyle(color: AppPallete.textPrimaryDark)),
        content: TextField(
          controller: _societyController,
          style: TextStyle(color: AppPallete.textPrimaryDark),
          decoration: InputDecoration(
            hintText: 'Enter society name',
            hintStyle: TextStyle(color: AppPallete.profileTextSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppPallete.profileTextSecondary),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppPallete.profileAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_societyController.text.isNotEmpty) {
                setState(() {
                  _societies.add(_societyController.text);
                  _societyController.clear();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeSociety(String society) {
    setState(() {
      _societies.remove(society);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _batchController.dispose();
    _branchController.dispose();
    _classController.dispose();
    _societyController.dispose();
    super.dispose();
  }
}