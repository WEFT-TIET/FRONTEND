import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/home/view/Drawer/drawer.dart';
import 'package:frontend_weft/features/home/view/widgets/animated_app_bar.dart';
import 'package:frontend_weft/features/home/view/widgets/search_bar_widget.dart';
import 'package:frontend_weft/features/home/view/widgets/filter_chips_widget.dart';
import 'package:frontend_weft/features/post/view/widgets/post_card.dart';
import 'package:frontend_weft/features/post/viewmodel/post_viewmodel.dart';
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
        body: _buildOptimizedBody(),
      ),
    );
  }

  Widget _buildOptimizedBody() {
    return CustomScrollView(
      slivers: [
        // Welcome Card Section
        // SliverToBoxAdapter(
        //   child: Padding(
        //     padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        //     child: RepaintBoundary(
        //       //child: WelcomeCard(animation: _animation),
        //     ),
        //   ),
        // ),

        // Search Bar Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 2.0,
            ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
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
            child: RepaintBoundary(child: _buildSectionHeader()),
          ),
        ),

        // Posts List Section - Inline implementation
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              RepaintBoundary(
                child: _buildPostsList(),
              ),
            ]),
          ),
        ),

        // Bottom padding for FAB
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Text(
      "All Wefs",
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

  // Inline posts list implementation
  Widget _buildPostsList() {
    final postState = ref.watch(postViewModelProvider);

    // Show loading state for initial load
    if (postState.isLoading && postState.posts.isEmpty) {
      return _buildLoadingState();
    }

    // Show error state
    if (postState.error != null && postState.posts.isEmpty) {
      return _buildErrorState(postState.error!);
    }

    final filteredPosts = _getFilteredPosts(postState.posts);
    
    if (filteredPosts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(postViewModelProvider.notifier).refreshPosts();
      },
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredPosts.length,
        itemBuilder: (context, index) {
          final post = filteredPosts[index];
          
          // Simple verification check: known verified usernames
          final isVerified = _isUserVerified(post.username);

          return RepaintBoundary(
            child: PostCard(
              key: ValueKey('post_${post.id}'),
              postId: post.id,
              userId: post.userId,
              username: post.username,
              tag: post.title,
              timeAgo: _formatTimeAgo(post.createdAt),
              content: post.content,
              stars: post.likesCount,
              comments: post.commentsCount,
              liked: post.liked,
              verified: isVerified,
            ),
          );
        },
      ),
    );
  }

  // Simple verification check based on known patterns
  bool _isUserVerified(String username) {
    // Known verified usernames (users with @thapar.edu emails)
    const verifiedUsers = {
      'rudiee', // Current user with @thapar.edu email
    };
    
    return verifiedUsers.contains(username.toLowerCase());
  }

  List<dynamic> _getFilteredPosts(List<dynamic> posts) {
    // Filter posts based on search query
    var filteredPosts = _searchQuery.isEmpty
        ? posts
        : posts.where((post) => post.title
            .toLowerCase()
            .contains(_searchQuery.toLowerCase())).toList();

    // Apply filter
    switch (_selectedFilter) {
      case 'Recent':
        filteredPosts.sort((a, b) => 
          DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));
        break;
      case 'Popular':
        filteredPosts.sort((a, b) => b.likesCount.compareTo(a.likesCount));
        break;
      case 'All':
      default:
        // Keep original order
        break;
    }

    return filteredPosts;
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPallete.gradient1.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppPallete.gradient2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading posts...',
            style: GoogleFonts.getFont(
              'Oswald',
              color: AppPallete.textPrimaryDark.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPallete.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: AppPallete.red.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: GoogleFonts.getFont(
              'Oswald',
              color: AppPallete.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Don\'t worry, we\'ll fix this!',
            style: GoogleFonts.getFont(
              'Oswald',
              color: AppPallete.textPrimaryDark.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(postViewModelProvider.notifier).refreshPosts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.gradient2,
              foregroundColor: AppPallete.whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: Text(
              'Try Again',
              style: GoogleFonts.getFont(
                'Oswald',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPallete.whiteColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _searchQuery.isEmpty ? Icons.post_add : Icons.search_off,
              size: 64,
              color: AppPallete.textPrimaryDark.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No posts yet' : 'No matching posts found',
            style: GoogleFonts.getFont(
              'Oswald',
              color: AppPallete.textPrimaryDark.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Be the first to share something!'
                : 'Try a different search term',
            style: GoogleFonts.getFont(
              'Oswald',
              color: AppPallete.textPrimaryDark.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final difference = DateTime.now().difference(dateTime);

      if (difference.inMinutes < 1) return 'just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      return '${difference.inDays}d ago';
    } catch (e) {
      return 'unknown';
    }
  }
}
