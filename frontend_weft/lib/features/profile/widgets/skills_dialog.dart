import 'package:flutter/material.dart';

class SkillsDialog extends StatefulWidget {
  final List<String> currentSkills;
  final Function(List<String>) onSkillsUpdated;
  
  const SkillsDialog({
    super.key,
    required this.currentSkills,
    required this.onSkillsUpdated,
  });

  @override
  State<SkillsDialog> createState() => _SkillsDialogState();
}

class _SkillsDialogState extends State<SkillsDialog> {
  late List<String> _skills;
  final TextEditingController _skillController = TextEditingController();

  // Popular skills suggestions
  final List<String> _popularSkills = [
    'Python', 'JavaScript', 'Java', 'React', 'Flutter', 'Node.js',
    'HTML/CSS', 'SQL', 'Git', 'Docker', 'AWS', 'Firebase',
    'Machine Learning', 'Data Science', 'Web Development',
    'Mobile Development', 'UI/UX Design', 'Cybersecurity',
    'DevOps', 'Blockchain', 'Artificial Intelligence', 'Cloud Computing',
    'Database Management', 'API Development', 'Testing'
  ];

  @override
  void initState() {
    super.initState();
    _skills = List.from(widget.currentSkills);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF2A2D5A).withValues(alpha: 0.95),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 25,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Manage Skills',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Add skill field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D3A).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: TextField(
                  controller: _skillController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a skill...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    prefixIcon: Icon(
                      Icons.add,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF6366F1)),
                      onPressed: _addSkill,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => _addSkill(),
                ),
              ),
              const SizedBox(height: 16),

              // Current skills
              if (_skills.isNotEmpty) ...[
                Text(
                  'Your Skills (${_skills.length})',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills.map((skill) => _buildSkillChip(skill, true)).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Popular skills
              Text(
                'Popular Skills',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _popularSkills
                        .where((skill) => !_skills.contains(skill))
                        .map((skill) => _buildSkillChip(skill, false))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Cancel',
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.7),
                      () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      'Save',
                      const Color(0xFF6366F1),
                      Colors.white,
                      () {
                        widget.onSkillsUpdated(_skills);
                        Navigator.pop(context);
                      },
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

  Widget _buildSkillChip(String skill, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _skills.remove(skill);
            } else {
              if (!_skills.contains(skill)) {
                _skills.add(skill);
              }
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6366F1).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6366F1)
                  : Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                skill,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }
}
