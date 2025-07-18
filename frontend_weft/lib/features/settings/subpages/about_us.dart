import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

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
      child: Scaffold(
        backgroundColor: AppPallete.transperantColor,
        appBar: AppBar(
          title: const Text(
            'About Us',
            style: TextStyle(
              color: AppPallete.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppPallete.transperantColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Description
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppPallete.cardColorDark.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppPallete.textPrimaryDark.withOpacity(0.2),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About WEFT',
                        style: TextStyle(
                          color: AppPallete.textPrimaryDark,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'WEFT is a social platform designed to connect students and professionals, fostering meaningful relationships and collaborative opportunities in the digital age.',
                        style: TextStyle(
                          color: AppPallete.textPrimaryDark,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Team Section Title
                const Text(
                  'Meet Our Team',
                  style: TextStyle(
                    color: AppPallete.textPrimaryDark,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Team Members Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.98, // Increased to make tiles shorter from bottom
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: teamMembers.length,
                  itemBuilder: (context, index) {
                    return TeamMemberCard(member: teamMembers[index]);
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Contact Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppPallete.cardColorDark.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppPallete.textPrimaryDark.withOpacity(0.2),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Get in Touch',
                        style: TextStyle(
                          color: AppPallete.textPrimaryDark,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Have questions or feedback? We\'d love to hear from you!',
                        style: TextStyle(
                          color: AppPallete.textPrimaryDark,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            color: AppPallete.textPrimaryDark,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'weftatwork@gmail.com',
                            style: TextStyle(
                              color: AppPallete.textPrimaryDark,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TeamMemberCard extends StatelessWidget {
  final TeamMember member;

  const TeamMemberCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPallete.cardColorDark.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppPallete.textPrimaryDark.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // Reduced padding
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important: Use min size
          children: [
            // Profile Picture
            Container(
              width: 60, // Reduced from 80
              height: 60, // Reduced from 80
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppPallete.textPrimaryDark.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30), // Adjusted radius
                child: member.photoUrl.isNotEmpty
                    ? Image.network(
                        member.photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar();
                        },
                      )
                    : _buildDefaultAvatar(),
              ),
            ),
            const SizedBox(height: 8), // Reduced spacing
            
            // Name
            Text(
              member.name,
              style: const TextStyle(
                color: AppPallete.textPrimaryDark,
                fontSize: 14, // Reduced from 16
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2), // Reduced spacing
            
            // Role
            Text(
              member.role,
              style: TextStyle(
                color: AppPallete.textPrimaryDark.withOpacity(0.8),
                fontSize: 12, // Reduced from 14
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6), // Reduced spacing
            
            // Branch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Reduced padding
              decoration: BoxDecoration(
                color: AppPallete.textPrimaryDark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                member.branch,
                style: TextStyle(
                  color: AppPallete.textPrimaryDark.withOpacity(0.9),
                  fontSize: 10, // Reduced from 12
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8), // Reduced spacing
            
            // Instagram Button
            if (member.instagramId.isNotEmpty)
              Flexible( // Wrap with Flexible to prevent overflow
                child: GestureDetector(
                  onTap: () => _openInstagram(member.instagramId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced padding
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF833AB4), Color(0xFFE1306C), Color(0xFFFD1D1D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            '@${member.instagramId}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10, // Reduced from 12
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppPallete.textPrimaryDark.withOpacity(0.1),
      ),
      child: Icon(
        Icons.person,
        color: AppPallete.textPrimaryDark.withOpacity(0.6),
        size: 30, // Reduced from 40
      ),
    );
  }

  void _openInstagram(String instagramId) async {
    final url = 'https://instagram.com/$instagramId';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}

class TeamMember {
  final String name;
  final String role;
  final String branch;
  final String instagramId;
  final String photoUrl;

  TeamMember({
    required this.name,
    required this.role,
    required this.branch,
    required this.instagramId,
    required this.photoUrl,
  });
}

// Sample team members data - replace with your actual team
final List<TeamMember> teamMembers = [
  TeamMember(
    name: 'Prince Sharma',
    role: 'Co-Founder & Lead Developer',
    branch: 'COE',
    instagramId: 'tanice_gawd',
    photoUrl: 'https://via.placeholder.com/150', // Replace with actual photo URL
  ),
  TeamMember(
    name: 'Shashwat Narwal',
    role: 'Co-Founder & Video Editor',
    branch: 'AI&ML',
    instagramId: 'shshwt_',
    photoUrl: 'https://via.placeholder.com/150', // Replace with actual photo URL
  ),
  TeamMember(
    name: 'Gurneet Singh',
    role: 'Backend Developer',
    branch: 'COPC',
    instagramId: 'gurneet_singh12345',
    photoUrl: 'https://via.placeholder.com/150', // Replace with actual photo URL
  ),
  TeamMember(
    name: 'Vatsal Gupta',
    role: 'Frontend Developer',
    branch: 'COE',
    instagramId: 'vatsal.gupta06',
    photoUrl: 'https://via.placeholder.com/150', // Replace with actual photo URL
  ),
  TeamMember(
    name: 'Krishna Vig',
    role: 'Designer',
    branch: 'COE',
    instagramId: 'vig.krishna19',
    photoUrl: 'https://via.placeholder.com/150', // Replace with actual photo URL
  ),
  TeamMember(
    name: 'Samridhi Sharma',
    role: 'UI/UX Designer',
    branch: 'COE',
    instagramId: 'samridhi.s14',
    photoUrl: 'https://via.placeholder.com/150', // Replace with actual photo URL
  ),
];