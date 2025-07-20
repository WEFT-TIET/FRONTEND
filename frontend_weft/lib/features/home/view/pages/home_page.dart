import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
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
  Timer? _debounceTimer;

  final List<String> _filters = ['All', 'Recent', 'Popular'];

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
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
    _debounceTimer?.cancel();
    super.dispose();
  }

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
        backgroundColor: AppPallete.transperantColor,
        appBar: AnimatedAppBar(animation: _animation),
        drawer: const DrawerWidget(),
        floatingActionButton: _buildFloatingActionButton(),
        body: _buildOptimizedBody(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return RepaintBoundary(
      child: FloatingActionButton.extended(
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
    );
  }

  Widget _buildOptimizedBody() {
    return CustomScrollView(
      slivers: [
        // Welcome Card Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: RepaintBoundary(
              child: WelcomeCard(animation: _animation),
            ),
          ),
        ),

        // Search Bar Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: RepaintBoundary(
              child: SearchBarWidget(
                controller: _searchController,
                isSearchFocused: _isSearchFocused,
                onSearchChanged: _debouncedSearch,
                onFocusChanged: _handleFocusChange,
                onClear: _handleClearSearch,
              ),
            ),
          ),
        ),

        // Filter Chips Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: RepaintBoundary(
              child: FilterChipsWidget(
                filters: _filters,
                selectedFilter: _selectedFilter,
                onFilterChanged: _handleFilterChange,
              ),
            ),
          ),
        ),

        // Section Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: RepaintBoundary(
              child: _buildSectionHeader(),
            ),
          ),
        ),

        // Posts List Section - Optimized with SliverList
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              RepaintBoundary(
                child: PostsListWidget(
                  searchQuery: _searchQuery,
                  selectedFilter: _selectedFilter,
                ),
              ),
            ]),
          ),
        ),

        // Bottom padding for FAB
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
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

  // Optimized search with debouncing
  void _debouncedSearch(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      }
    });
  }

  // Optimized focus handling
  void _handleFocusChange(bool focused) {
    if (mounted) {
      setState(() {
        _isSearchFocused = focused;
      });
    }
  }

  // Optimized clear search
  void _handleClearSearch() {
    if (mounted) {
      setState(() {
        _searchQuery = '';
        _searchController.clear();
        _isSearchFocused = false;
      });
    }
  }

  // Optimized filter change
  void _handleFilterChange(String filter) {
    if (mounted) {
      setState(() {
        _selectedFilter = filter;
      });
    }
  }

  void _showCreatePostDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CreatePostDialog(ref: ref),
    );
  }
}