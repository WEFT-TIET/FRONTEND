import 'package:flutter/material.dart';
import 'package:frontend_weft/core/utils/responsive_utils.dart';
import 'package:frontend_weft/core/utils/responsive_text_styles.dart';
import 'package:frontend_weft/core/widgets/responsive_profile_name.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class ResponsiveTestPage extends StatelessWidget {
  const ResponsiveTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Responsive Test',
            style: ResponsiveTextStyles.getHeading2(context).copyWith(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: context.responsivePadding(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen info
              Container(
                padding: context.responsivePadding(),
                decoration: BoxDecoration(
                  borderRadius: context.responsiveBorderRadius(16),
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Screen Info',
                      style: ResponsiveTextStyles.getHeading3(context).copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing(8)),
                    Text(
                      'Width: ${context.screenWidth.toStringAsFixed(0)}px',
                      style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      'Height: ${context.screenHeight.toStringAsFixed(0)}px',
                      style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      'Device Type: ${context.isSmallScreen ? "Small" : context.isMediumScreen ? "Medium" : "Large"}',
                      style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: context.responsiveSpacing(24)),
              
              // Profile name test
              Container(
                padding: context.responsivePadding(),
                decoration: BoxDecoration(
                  borderRadius: context.responsiveBorderRadius(16),
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Name Tests',
                      style: ResponsiveTextStyles.getHeading3(context).copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing(16)),
                    
                    // Short name
                    Container(
                      width: 200,
                      padding: EdgeInsets.all(context.responsiveSpacing(8)),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        borderRadius: context.responsiveBorderRadius(8),
                      ),
                      child: const ResponsiveProfileName(
                        name: 'John Doe',
                        isVerified: true,
                      ),
                    ),
                    
                    SizedBox(height: context.responsiveSpacing(16)),
                    
                    // Long name
                    Container(
                      width: 180,
                      padding: EdgeInsets.all(context.responsiveSpacing(8)),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        borderRadius: context.responsiveBorderRadius(8),
                      ),
                      child: const ResponsiveProfileName(
                        name: 'Rudra Pratap Singh Yadav',
                        isVerified: true,
                      ),
                    ),
                    
                    SizedBox(height: context.responsiveSpacing(16)),
                    
                    // Very long name
                    Container(
                      width: 150,
                      padding: EdgeInsets.all(context.responsiveSpacing(8)),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        borderRadius: context.responsiveBorderRadius(8),
                      ),
                      child: const ResponsiveProfileName(
                        name: 'Alexander Hamilton Washington',
                        isVerified: false,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: context.responsiveSpacing(24)),
              
              // Typography test
              Container(
                padding: context.responsivePadding(),
                decoration: BoxDecoration(
                  borderRadius: context.responsiveBorderRadius(16),
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Typography Sizes',
                      style: ResponsiveTextStyles.getHeading1(context).copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing(8)),
                    Text(
                      'Heading 2',
                      style: ResponsiveTextStyles.getHeading2(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    Text(
                      'Heading 3',
                      style: ResponsiveTextStyles.getHeading3(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    Text(
                      'Body Large - This is a longer text to test how it looks on different screen sizes',
                      style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      'Body Medium - Regular text for descriptions',
                      style: ResponsiveTextStyles.getBodyMedium(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      'Body Small - Small details and captions',
                      style: ResponsiveTextStyles.getBodySmall(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: context.responsiveSpacing(100)),
            ],
          ),
        ),
      ),
    );
  }
}
