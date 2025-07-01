import 'package:flutter/material.dart';
import 'dart:ui';

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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B2E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header
              const SizedBox(height: 10),
              const Text(
                'WEFT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 20),

              // Profile Card with Glass Effect
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
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
                                  color: const Color(0xFF6366F1),
                                  shape: BoxShape.circle,
                                  border: _isEditing ? Border.all(color: Colors.white, width: 2) : null,
                                ),
                                child: _isEditing
                                    ? const Icon(Icons.camera_alt, color: Colors.white, size: 28)
                                    : const Center(
                                        child: Text(
                                          'Img',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
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
                                  itemCount: _societies.length + (_isEditing ? 1 : 0), // Only add button in edit mode
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white54),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF6366F1)),
                                    ),
                                  ),
                                )
                              : Row(
                                  children: [
                                    Text(
                                      _nameController.text,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3B3F5C),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'House',
                                        style: TextStyle(
                                          color: Color(0xFFB0B3C7),
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
                                const Color(0xFF3B3F5C),
                                Colors.white,
                                _toggleEdit,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMainButton(
                                'Share',
                                const Color(0xFF6366F1),
                                Colors.white,
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Wefts',
                  style: TextStyle(
                    color: Colors.white,
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
    );
  }

  Widget _buildSocietyChip(String society) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3B3F5C),
        borderRadius: BorderRadius.circular(12),
        border: _isEditing ? Border.all(color: Colors.red.withOpacity(0.5)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            society,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_isEditing) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _removeSociety(society),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.red,
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
          color: const Color(0xFF6366F1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMoreOptionsButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3B3F5C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.more_horiz,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildDetailColumn(String title, TextEditingController controller, bool isEditing) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFB0B3C7),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6366F1)),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              )
            : Text(
                controller.text,
                style: const TextStyle(
                  color: Colors.white,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Time Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      color: Color(0xFFB0B3C7),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Color(0xFFB0B3C7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: const TextStyle(
                  color: Colors.white,
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
                      color: const Color(0xFF3B3F5C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          likes.toString(),
                          style: const TextStyle(
                            color: Colors.white,
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
                      color: const Color(0xFF3B3F5C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          comments.toString(),
                          style: const TextStyle(
                            color: Colors.white,
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
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Save changes logic here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    });
  }

  void _shareProfile() {
    // Share profile logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile shared!')),
    );
  }

  void _showImagePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2D47),
        title: const Text('Change Profile Picture', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Camera', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Implement camera functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Gallery', style: TextStyle(color: Colors.white)),
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
        backgroundColor: const Color(0xFF2A2D47),
        title: const Text('Add Society', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _societyController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter society name',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6366F1)),
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