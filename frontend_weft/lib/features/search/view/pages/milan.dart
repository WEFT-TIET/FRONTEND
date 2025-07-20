import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_milan.dart';

class Milan extends StatefulWidget {
  @override
  _MilanState createState() => _MilanState();
}

class _MilanState extends State<Milan> {
  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isRegistered = prefs.getBool('isRegistered') ?? false;

    if (!isRegistered) {
      // Use a post-frame callback to navigate after the build method completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RegistrationPage()),
        );
      });
    }
  }

  final List<Map<String, String>> profiles = [
    {
      'name': 'Rudra Yadav',
      'image': 'lib/core/assets/profile_photo.jpeg',
      'bio': 'Loves chai & coding 💻☕'
    },
    {
      'name': 'Neeraj Pepsu',
      'image': 'lib/core/assets/neeraj_pepsu.png',
      'bio': 'Final year mechie 🔧'
    },
    {
      'name': 'Sanni Dancer',
      'image': 'lib/core/assets/sanni_dancer.png',
      'bio': 'Netflix + pizza = perfect night 🍕🎬'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.scaffoldBackgroundColorDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          " Campus Connects ",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            shadows: [
              Shadow(
                blurRadius: 8,
                color: AppPallete.secondaryDark.withOpacity(0.5),
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        backgroundColor: AppPallete.glassWhite05,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppPallete.primaryDark.withOpacity(0.8),
                AppPallete.secondaryDark.withOpacity(0.6),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppPallete.scaffoldBackgroundColorDark,
              AppPallete.gradient1,
              AppPallete.gradient2,
              AppPallete.gradient3,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Romantic header section
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        " Find best clg connections",
                        style: TextStyle(
                          color: AppPallete.textPrimaryDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: AppPallete.secondaryDark.withOpacity(0.3),
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Swipe right to connect with ur peers",
                        style: TextStyle(
                          color: AppPallete.profileTextSecondary,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Card swiper with love theme
                Expanded(
                  child: CardSwiper(
                    cardsCount: profiles.length,
                    cardBuilder: (BuildContext context, int index) {
                      final profile = profiles[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: AppPallete.secondaryDark.withOpacity(0.2),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                            BoxShadow(
                              color: AppPallete.primaryDark.withOpacity(0.1),
                              blurRadius: 30,
                              offset: Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppPallete.glassWhite10,
                                  AppPallete.glassWhite05,
                                ],
                              ),
                              border: Border.all(
                                color: AppPallete.glassWhite10,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Profile image with love overlay
                                Expanded(
                                  flex: 3,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                        child: Image.asset(
                                          profile['image']!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                      // Love gradient overlay
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              AppPallete.primaryDark.withOpacity(0.3),
                                              AppPallete.secondaryDark.withOpacity(0.6),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                        ),
                                      ),
                                      // Floating hearts decoration
                                      Positioned(
                                        top: 20,
                                        right: 20,
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppPallete.glassWhite20,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppPallete.glassWhite10,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            "😎",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Profile info with glassmorphism
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppPallete.cardColorDark.withOpacity(0.9),
                                          AppPallete.profileCardBackground.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                                      border: Border.all(
                                        color: AppPallete.glassWhite10,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          profile['name']!,
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: AppPallete.textPrimaryDark,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 8,
                                                color: AppPallete.secondaryDark.withOpacity(0.3),
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          profile['bio']!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppPallete.profileTextSecondary,
                                            height: 1.4,
                                            fontStyle: FontStyle.italic,
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
                    },
                    numberOfCardsDisplayed: 3,
                    isLoop: false,
                    onSwipe: (previousIndex, currentIndex, direction) {
                      final name = profiles[previousIndex ?? 0]['name'];
                      String? action;
                      Color snackBarColor;

                      switch (direction) {
                        case CardSwiperDirection.right:
                          action = "You're connecting with $name!";
                          snackBarColor = AppPallete.secondaryDark;
                          break;
                        case CardSwiperDirection.left:
                          action = "You passed on $name";
                          snackBarColor = AppPallete.red;
                          break;
                        default:
                          action = null;
                          snackBarColor = Colors.grey;
                      }

                      if (action != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Container(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    action,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: snackBarColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                        );
                      }
                    },
                  ),
                ),
                
                // Romantic action buttons
                Container(
                  padding: EdgeInsets.symmetric(vertical: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildGlassActionButton(
                        icon: Icons.close,
                        color: AppPallete.red,
                        label: "Pass",
                        onPressed: () {
                          // Handle pass action
                        },
                      ),
                      _buildGlassActionButton(
                        icon: Icons.favorite,
                        color: AppPallete.secondaryDark,
                        label: "Connect",
                        onPressed: () {
                          // Handle like action
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppPallete.glassWhite20,
                AppPallete.glassWhite10,
              ],
            ),
            border: Border.all(
              color: AppPallete.glassWhite10,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: color.withOpacity(0.8),
            heroTag: icon.toString(),
            elevation: 0,
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: AppPallete.profileTextSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}