import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/home/view/Drawer/soc_page/models/society_model.dart';
import 'package:frontend_weft/features/home/view/Drawer/soc_page/services/society_service.dart';
import 'package:google_fonts/google_fonts.dart';

class SocietyPage extends StatelessWidget {
  const SocietyPage({Key? key}) : super(key: key);

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
        body: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, 
                          color: AppPallete.textPrimaryDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'College Societies',
                        style: GoogleFonts.getFont(
                          'Oswald',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppPallete.textPrimaryDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              
              // Society List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: SocietyService.societies.length,
                  itemBuilder: (context, index) {
                    final society = SocietyService.societies[index];
                    return SocietyCard(society: society);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SocietyCard extends StatelessWidget {
  final Society society;

  const SocietyCard({Key? key, required this.society}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppPallete.whiteColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppPallete.whiteColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SocietyDetailPage(society: society),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppPallete.gradient1, AppPallete.gradient2],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      society.icon,
                      color: AppPallete.whiteColor,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          society.name,
                          style: GoogleFonts.getFont(
                            'Oswald',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppPallete.textPrimaryDark,
                          ),
                        ),
                        SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
              
              Text(
                society.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.getFont(
                  'Oswald',
                  fontSize: 14,
                  color: AppPallete.textPrimaryDark.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SocietyDetailPage extends StatelessWidget {
  final Society society;

  const SocietyDetailPage({Key? key, required this.society}) : super(key: key);

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
        body: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, 
                          color: AppPallete.textPrimaryDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        society.name,
                        style: GoogleFonts.getFont(
                          'Oswald',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppPallete.textPrimaryDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Society Info Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppPallete.whiteColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppPallete.whiteColor.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Society Logo
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppPallete.gradient1, AppPallete.gradient2],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppPallete.gradient1.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                society.icon,
                                color: AppPallete.whiteColor,
                                size: 50,
                              ),
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Society Name
                            Text(
                              society.fullName,
                              style: GoogleFonts.getFont(
                                'Oswald',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppPallete.textPrimaryDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Description Section
                      Text(
                        'About',
                        style: GoogleFonts.getFont(
                          'Oswald',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppPallete.textPrimaryDark,
                        ),
                      ),
                      
                      SizedBox(height: 12),
                      
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppPallete.whiteColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppPallete.whiteColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          society.description,
                          style: GoogleFonts.getFont(
                            'Oswald',
                            fontSize: 16,
                            color: AppPallete.textPrimaryDark.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Contact Information Section
                      if (society.instagramHandle.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppPallete.whiteColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppPallete.whiteColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connect With Us',
                                style: GoogleFonts.getFont(
                                  'Oswald',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppPallete.textPrimaryDark,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Find us on Instagram',
                                style: GoogleFonts.getFont(
                                  'Oswald',
                                  fontSize: 14,
                                  color: AppPallete.textPrimaryDark.withOpacity(0.8),
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF833AB4), Color(0xFFE1306C), Color(0xFFFD1D1D)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '@${society.instagramHandle}',
                                  style: GoogleFonts.getFont(
                                    'Oswald',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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