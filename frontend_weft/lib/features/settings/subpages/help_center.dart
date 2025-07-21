import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

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
            'Help Center',
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'How can we help you?',
                  style: TextStyle(
                    color: AppPallete.textPrimaryDark,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find answers or contact our support team',
                  style: TextStyle(
                    color: AppPallete.textPrimaryDark.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),

                // FAQ Section
                const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    color: AppPallete.textPrimaryDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // FAQ Items
                _buildFAQItem(
                  context,
                  question: 'How do I reset my password?',
                  answer: 'Go to your profile settings and select "Change Password". '
                      'If you forgot your password, use the "Forgot Password" option.',
                ),
                _buildFAQItem(
                  context,
                  question: 'How can I report a bug?',
                  answer: 'Navigate to Settings > Report a Bug and describe the issue you encountered. '
                      'Our team will review it promptly.',
                ),
                _buildFAQItem(
                  context,
                  question: 'Is my data secure?',
                  answer: 'Yes, we use industry-standard encryption to protect all your data. '
                      'We never share your information with third parties.',
                ),
                _buildFAQItem(
                  context,
                  question: 'How to search any student?',
                  answer: 'Navigate to the Search Page and click on the search icon. '
                      'You can search by name, branch, batch.',
                ),
                const SizedBox(height: 30),

                // Contact Section
                const Text(
                  'Still need help?',
                  style: TextStyle(
                    color: AppPallete.textPrimaryDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Contact Information (now as static text)
                _buildContactInfo(
                  icon: Icons.email,
                  title: 'Email Us',
                  subtitle: 'weftatwork@gmail.com',
                  info: 'Get a response within 24 hours',
                ),
                _buildContactInfo(
                  icon: Icons.chat,
                  title: 'Live Chat',
                  subtitle: 'Coming Soon',
                  info: 'Available 9AM-5PM (IST)',
                ),
                _buildContactInfo(
                  icon: Icons.phone,
                  title: 'Call Support',
                  subtitle: '+91 7023458736',
                  info: 'Mon-Fri, 9AM-5PM (IST)',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, {required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppPallete.cardColorDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppPallete.textPrimaryDark.withOpacity(0.2),
        ),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            color: AppPallete.textPrimaryDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        collapsedIconColor: AppPallete.textPrimaryDark,
        iconColor: AppPallete.textPrimaryDark,
        children: [
          Text(
            answer,
            style: TextStyle(
              color: AppPallete.textPrimaryDark.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String title,
    required String subtitle,
    required String info,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPallete.cardColorDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppPallete.textPrimaryDark.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppPallete.cardColorDark.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppPallete.textPrimaryDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppPallete.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppPallete.textPrimaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  info,
                  style: TextStyle(
                    color: AppPallete.textPrimaryDark.withOpacity(0.6),
                    fontSize: 12,
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