// lib/features/home/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/home/view/Drawer/drawer.dart';
import 'package:frontend_weft/features/home/view/widgets/animated_app_bar.dart';
import 'package:frontend_weft/features/home/view/widgets/welcome_card.dart';
import 'package:frontend_weft/features/home/view/widgets/search_bar_widget.dart';
import 'package:frontend_weft/features/home/view/widgets/filter_chips_widget.dart';
import 'package:frontend_weft/features/home/view/widgets/posts_list_widget.dart';
import 'package:frontend_weft/features/home/view/widgets/create_post_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchFocused = false;
  String _selectedFilter = 'All';
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<String> _filters = ['All', 'Recent', 'Popular'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

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
        appBar: AnimatedAppBar(animation: _animation),
        drawer: const DrawerWidget(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreatePostDialog(context, ref),
          backgroundColor: AppPallete.gradient2,
          icon: const Icon(Icons.add, color: AppPallete.whiteColor),
          label: Text(
            'Create Wef',
            style: GoogleFonts.getFont(
              'Oswald',
              color: AppPallete.whiteColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 8,
          heroTag: "createPost",
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WelcomeCard(animation: _animation),
                const SizedBox(height: 20),
                SearchBarWidget(
                  controller: _searchController,
                  isSearchFocused: _isSearchFocused,
                  onSearchChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  onFocusChanged: (focused) {
                    setState(() {
                      _isSearchFocused = focused;
                    });
                  },
                  onClear: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                      _isSearchFocused = false;
                    });
                  },
                ),
                const SizedBox(height: 20),
                FilterChipsWidget(
                  filters: _filters,
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildSectionHeader(),
                const SizedBox(height: 15),
                PostsListWidget(
                  searchQuery: _searchQuery,
                  selectedFilter: _selectedFilter,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Text(
      "STUDENTS' WEF'S",
      style: GoogleFonts.getFont(
        'Oswald',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppPallete.textPrimaryDark,
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CreatePostDialog(ref: ref),
    );
  }
}