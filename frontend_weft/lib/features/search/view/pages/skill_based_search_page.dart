import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/search/view/pages/wefter_results_page.dart';
import 'package:frontend_weft/core/services/user_service.dart';
import 'package:frontend_weft/core/http_client.dart';
import 'package:frontend_weft/core/utils/responsive_utils.dart';
import 'package:frontend_weft/core/utils/responsive_text_styles.dart';
import 'package:frontend_weft/core/config/responsive_config.dart';

class SkillBasedSearchPage extends ConsumerStatefulWidget {
  const SkillBasedSearchPage({super.key});

  @override
  ConsumerState<SkillBasedSearchPage> createState() => _SkillBasedSearchPageState();
}

class _SkillBasedSearchPageState extends ConsumerState<SkillBasedSearchPage> {
  final TextEditingController _skillController = TextEditingController();
  List<String> _selectedSkills = [];
  
  // Popular skills for quick search
  final List<String> _popularSkills = [
    'Python', 'JavaScript', 'Java', 'React', 'Flutter', 'Node.js',
    'HTML/CSS', 'SQL', 'Git', 'Docker', 'AWS', 'Firebase',
    'Machine Learning', 'Data Science', 'Web Development',
    'Mobile Development', 'UI/UX Design', 'Cybersecurity',
    'DevOps', 'Blockchain', 'Artificial Intelligence', 'Cloud Computing',
  ];

  @override
  void initState() {
    super.initState();
    // Listen to text changes to update selected skills
    _skillController.addListener(_updateSelectedSkillsList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                      SizedBox(height: context.responsiveSpacing(32)),
                      
                      // Search Field
                      _buildSearchField(),
                      SizedBox(height: context.responsiveSpacing(16)),
                      
                      // Selected Skills (if any)
                      if (_selectedSkills.isNotEmpty) _buildSelectedSkills(),
                      if (_selectedSkills.isNotEmpty) SizedBox(height: context.responsiveSpacing(16)),
                      
                      SizedBox(height: context.responsiveSpacing(16)),
                      
                      // Popular Skills
                      _buildPopularSkills(),
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
    final buttonSize = context.responsiveWidth(40);
    
    return Container(
      padding: context.responsivePadding(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: context.responsiveBorderRadius(12),
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
                'Skills Search',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.stars,
                color: Color(0xFF6366F1),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find by Skills',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Search for students with specific skills',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3A3E7A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _skillController,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Enter skills separated by commas (e.g., Python, ML, React)...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withValues(alpha: 0.6),
            size: 22,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _searchBySkills(_skillController.text.trim()),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onSubmitted: _searchBySkills,
      ),
    );
  }

  Widget _buildPopularSkills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Skills',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to add skills to your search',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _popularSkills.map((skill) => _buildSkillChip(skill)).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String skill) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _addSkillToTextField(skill),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.stars,
                color: Color(0xFF6366F1),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                skill,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedSkills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Skills',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF3A3E7A).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedSkills.map((skill) => _buildSelectedSkillChip(skill)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeSkillFromTextField(skill),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _updateSelectedSkillsList() {
    String currentText = _skillController.text.trim();
    if (currentText.isEmpty) {
      setState(() {
        _selectedSkills = [];
      });
    } else {
      setState(() {
        _selectedSkills = currentText
            .split(',')
            .map((skill) => skill.trim())
            .where((skill) => skill.isNotEmpty)
            .toList();
      });
    }
  }

  void _removeSkillFromTextField(String skillToRemove) {
    List<String> currentSkills = _selectedSkills.where((skill) => skill != skillToRemove).toList();
    _skillController.text = currentSkills.join(', ');
    _updateSelectedSkillsList();
  }

  void _addSkillToTextField(String skill) {
    String currentText = _skillController.text.trim();
    
    if (currentText.isEmpty) {
      // If text field is empty, just add the skill
      _skillController.text = skill;
    } else {
      // Check if skill is already in the text field
      List<String> currentSkills = currentText.split(',').map((s) => s.trim()).toList();
      if (!currentSkills.contains(skill)) {
        // Add comma and the new skill
        _skillController.text = '$currentText, $skill';
      }
    }
    
    // Move cursor to the end
    _skillController.selection = TextSelection.fromPosition(
      TextPosition(offset: _skillController.text.length),
    );
    
    // Update selected skills list
    _updateSelectedSkillsList();
  }

  void _searchBySkills(String skillsInput) async {
    if (skillsInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter skills to search'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Parse multiple skills separated by commas
    List<String> skills = skillsInput
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();

    if (skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid skills to search'),
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2d2d4a),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366f1)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Finding students with skills:\n${skills.join(', ')}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
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
      
      // For now, join skills with commas until backend supports multiple skills
      // When you integrate the backend, you can modify this to handle multiple skills properly
      final skillsQuery = skills.join(', ');
      final result = await UserService.searchUsers(
        skill: skillsQuery, // Pass the combined skills string for now
        client: appHttpClient,
      );

      // Hide loading dialog
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      if (result['success']) {
        final users = result['data'] as List<dynamic>? ?? [];
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WEFTerResultsPage(users: users),
            ),
          );
        }
      } else {
        if (mounted) _showErrorDialog(result['error']);
      }
    } catch (e) {
      // Hide loading dialog
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (mounted) _showErrorDialog('Network error: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2d2d4a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
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
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF6366f1)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }
}
