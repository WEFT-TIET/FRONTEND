import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/core/widgets/pull_to_refresh_wrapper.dart';
import 'package:frontend_weft/features/profile/models/user_model.dart';
import 'package:frontend_weft/features/profile/models/skill_model.dart';
import 'package:frontend_weft/features/profile/services/skills_api_service.dart';
import 'package:frontend_weft/features/profile/pages/profile_page.dart';

class SkillsManagementPage extends ConsumerStatefulWidget {
  final UserModel user;

  const SkillsManagementPage({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<SkillsManagementPage> createState() =>
      _SkillsManagementPageState();
}

class _SkillsManagementPageState extends ConsumerState<SkillsManagementPage> {
  // CHANGED: The list now correctly holds SkillModel objects
  late List<SkillModel> _skills;
  final TextEditingController _skillController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // This now works because widget.user.skills is a List<SkillModel>
    _skills = List.from(widget.user.skills);
  }

  Future<void> _handleRefresh() async {
    try {
      // Refresh the user profile to get updated skills
      ref.invalidate(userProfileProvider);
      
      // Wait a moment for the provider to refresh
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Update local skills list with the refreshed data
      final refreshedUser = ref.read(userProfileProvider).value;
      if (refreshedUser != null) {
        setState(() {
          _skills = List.from(refreshedUser.skills);
        });
      }
      
      HapticFeedback.lightImpact();
    } catch (e) {
      // Handle refresh error silently or show a subtle message
      print('Refresh error: $e');
    }
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
          child: PullToRefreshWrapper(
            onRefresh: _handleRefresh,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildAddSkillField(),
                        const SizedBox(height: 24),
                        _buildSkillsList(),
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

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Manage Skills',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40), // Balance for centered title
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.3),
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
                'Your Skills',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Add or remove your technical skills',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddSkillField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3A3E7A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _skillController,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Add a new skill...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.add_circle_outline,
            color: Colors.white.withOpacity(0.6),
            size: 22,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _isLoading ? null : _addSkill,
            ),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onSubmitted: _isLoading ? null : (_) => _addSkill(),
      ),
    );
  }

  Widget _buildSkillsList() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Your Skills',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_skills.length}',
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_skills.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.stars_outlined,
                      color: Colors.white.withOpacity(0.4),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No skills added yet',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first skill above',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3E7A).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _skills.length,
                  itemBuilder: (context, index) {
                    return _buildSkillItem(index);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkillItem(int index) {
    final skill = _skills[index];
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.star, color: Color(0xFF818CF8)),
        title: Text(
          // CHANGED: Display the skill's name property
          skill.skillName,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _confirmRemoveSkill(index),
        ),
      ),
    );
  }

  void _addSkill() async {
    final skillName = _skillController.text.trim();
    if (skillName.isEmpty) return;

    // CHANGED: Check against the skillName property of each SkillModel
    if (_skills.any((s) => s.skillName.toLowerCase() == skillName.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This skill already exists.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final skillsApi = ref.read(skillsApiServiceProvider);
      final result = await skillsApi.addSkill(skillName);

      if (result != null && result['success'] == true) {
        // CHANGED: Invalidate the provider to refetch the user's profile
        // with the new skill (including its server-generated ID).
        // This is more reliable than adding a temporary object locally.
        ref.invalidate(userProfileProvider);
        HapticFeedback.lightImpact();
        _skillController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Skill added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add skill. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _removeSkill(int index) async {
    // This function now works correctly.
    final skillToRemove = _skills[index];

    try {
      final skillsApi = ref.read(skillsApiServiceProvider);
      final success = await skillsApi.removeSkill(skillToRemove.id);

      if (success) {
        setState(() {
          _skills.removeAt(index);
        });
        // Invalidate the profile provider to ensure data consistency everywhere.
        ref.invalidate(userProfileProvider);
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Skill removed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove skill. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmRemoveSkill(int index) {
    // CHANGED: Get the skill name from the SkillModel object
    final skillName = _skills[index].skillName;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Remove Skill'),
          content: Text('Are you sure you want to remove "$skillName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeSkill(index);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Remove'),
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