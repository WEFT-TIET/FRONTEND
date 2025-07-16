import 'package:flutter/material.dart';
import 'package:frontend_weft/features/home/view/Drawer/soc_page/models/society_model.dart';
import 'package:frontend_weft/features/home/view/Drawer/soc_page/services/society_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SocietyPage extends StatelessWidget {
  const SocietyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 99, 102, 241),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'College Societies',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // For balance
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
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
                        colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      society.icon,
                      color: Colors.white,
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                society.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[700],
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f4c75),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        society.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
                          color: Color(0x0DFFFFFF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Color(0x33FFFFFF), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
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
                                  colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF6366f1).withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                society.icon,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Society Name
                            Text(
                              society.fullName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Description Section
                      Text(
                        'About',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      SizedBox(height: 12),
                      
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0x0DFFFFFF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0x33FFFFFF), width: 1),
                        ),
                        child: Text(
                          society.description,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Contact/Join Section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0x0DFFFFFF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0x33FFFFFF), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Get Involved',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Interested in joining ${society.name}? Connect with us through our events and activities.',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
  child: ElevatedButton(
    onPressed: () async {
      if (society.instagramHandle.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No Instagram available for ${society.name}'),
            backgroundColor: Color(0xFF6366f1),
          ),
        );
        return;
      }

      final instaUrl = 'https://instagram.com/${society.instagramHandle}';
      final uri = Uri.parse(instaUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch Instagram'),
            backgroundColor: Color(0xFF6366f1),
          ),
        );
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF6366f1),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Text(
      'Contact',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
                                SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Follow feature coming soon!'),
                                          backgroundColor: Color(0xFF8b5cf6),
                                          duration: Duration(milliseconds: 500), 
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF8b5cf6),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Follow',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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