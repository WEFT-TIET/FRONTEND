import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import '../widgets/profile_info_row.dart';
import '../widgets/profile_edit_field.dart';
import '../widgets/wef_card.dart';
import '../../model/share_modal.dart';
import '../../model/badge_modal.dart';

final List<Map<String, dynamic>> badges = [
  {'icon': Icons.emoji_events, 'label': 'Top Contributor', 'description': 'Awarded for being a top contributor in the community.', 'color': Colors.amber},
  {'icon': Icons.star, 'label': '100+ Posts', 'description': 'Awarded for making over 100 posts.', 'color': Colors.blueAccent},
  {'icon': Icons.group, 'label': 'Batch Rep', 'description': 'Awarded for representing your batch.', 'color': Colors.green},
];


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController(text: 'Rudra Yadav');
  final TextEditingController _batchController = TextEditingController(text: '2025');
  final TextEditingController _branchController = TextEditingController(text: 'COE');
  final TextEditingController _classController = TextEditingController(text: '1A62');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final accent = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: AppPallete.scaffoldBackgroundColorDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 2,
            backgroundColor: theme.scaffoldBackgroundColor,
            automaticallyImplyLeading: false,
            title: const Text('Profile (Student)', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () {})],
          ),
          SliverToBoxAdapter(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 100, left: 16, right: 16),
                  padding: const EdgeInsets.only(top: 70, left: 24, right: 24, bottom: 24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha((0.08 * 255).toInt()), blurRadius: 16, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text('@rudie', style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withAlpha((0.6 * 255).toInt()), fontStyle: FontStyle.italic)),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 48,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: badges.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final badge = badges[index];
                              return GestureDetector(
                                onTap: () => showBadgeModal(context, badge),
                                child: Tooltip(
                                  message: badge['label'],
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: badge['color'],
                                    child: Icon(badge['icon'], color: Colors.white, size: 20),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                        child: !_isEditing
                            ? Column(
                                key: const ValueKey('display'),
                                children: [
                                  ProfileInfoRow(icon: Icons.person, label: 'Name', value: _nameController.text),
                                  const SizedBox(height: 8),
                                  ProfileInfoRow(icon: Icons.school, label: 'Batch', value: _batchController.text),
                                  const SizedBox(height: 8),
                                  ProfileInfoRow(icon: Icons.account_tree, label: 'Branch', value: _branchController.text),
                                  const SizedBox(height: 8),
                                  ProfileInfoRow(icon: Icons.class_, label: 'Class', value: _classController.text),
                                ],
                              )
                            : Column(
                                key: const ValueKey('edit'),
                                children: [
                                  ProfileEditField(icon: Icons.person, label: 'Name', controller: _nameController),
                                  const SizedBox(height: 8),
                                  ProfileEditField(icon: Icons.school, label: 'Batch', controller: _batchController),
                                  const SizedBox(height: 8),
                                  ProfileEditField(icon: Icons.account_tree, label: 'Branch', controller: _branchController),
                                  const SizedBox(height: 8),
                                  ProfileEditField(icon: Icons.class_, label: 'Class', controller: _classController),
                                ],
                              ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              elevation: 0,
                            ),
                            onPressed: () => setState(() => _isEditing = !_isEditing),
                            child: Text(_isEditing ? 'Save' : 'Edit Profile'),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              side: BorderSide(color: accent, width: 2),
                              foregroundColor: accent,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            onPressed: () => showShareModal(context, accent),
                            child: const Text('Share Profile'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Your Wef', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: accent)),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          separatorBuilder: (context, index) => const SizedBox(width: 16),
                          itemBuilder: (context, index) => WefCard(
                            title: 'Wef Title ${index + 1}',
                            subtitle: 'Description for Wef ${index + 1}',
                            accent: accent,
                            cardColor: cardColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 24,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [accent.withAlpha((0.7 * 255).toInt()), accent.withAlpha((0.2 * 255).toInt()), Colors.transparent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [BoxShadow(color: accent.withAlpha((0.25 * 255).toInt()), blurRadius: 18, offset: const Offset(0, 8))],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.scaffoldBackgroundColor,
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.1 * 255).toInt()), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: ClipOval(
                        child: Image.asset('lib/core/assets/profile_photo.jpeg', fit: BoxFit.cover, width: 92, height: 92),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
