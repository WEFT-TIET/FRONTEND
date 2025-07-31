import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/core/theme/theme.dart';
import '../services/trusted_users_service.dart';
import '../models/trusted_user_model.dart';
import '../widgets/trusted_user_tile.dart';
import '../widgets/search_user_tile.dart';

class TrustedUsersPage extends ConsumerStatefulWidget {
  const TrustedUsersPage({super.key});

  @override
  ConsumerState<TrustedUsersPage> createState() => _TrustedUsersPageState();
}

class _TrustedUsersPageState extends ConsumerState<TrustedUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  List<TrustedUserModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trustedUsersProvider.notifier).loadTrustedUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await ref.read(trustedUsersProvider.notifier).searchUsers(query);
    
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileTheme = theme.extension<ProfileTheme>();
    
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppPallete.glassWhite10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppPallete.glassWhite20,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Trusted Users',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                                         Consumer(
                       builder: (context, ref, child) {
                         final trustedUsersState = ref.watch(trustedUsersProvider);
                         return Container(
                          decoration: BoxDecoration(
                            color: AppPallete.glassWhite10,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppPallete.glassWhite20,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Icon(
                                  Icons.visibility_off,
                                                                   color: trustedUsersState.isGhostModeEnabled 
                                     ? AppPallete.secondaryDark 
                                     : Colors.white70,
                                  size: 20,
                                ),
                              ),
                                                             Switch(
                                 value: trustedUsersState.isGhostModeEnabled,
                                 onChanged: (value) => ref.read(trustedUsersProvider.notifier).toggleGhostMode(),
                                activeColor: AppPallete.secondaryDark,
                                activeTrackColor: AppPallete.glassWhite20,
                                inactiveThumbColor: Colors.white70,
                                inactiveTrackColor: AppPallete.glassWhite05,
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Text(
                                  'Ghost',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppPallete.glassWhite10,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppPallete.glassWhite20,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search users to add to trusted list...',
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.white70),
                              onPressed: () {
                                _searchController.clear();
                                _searchUsers('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      _searchUsers(value);
                    },
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Content
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final trustedUsersState = ref.watch(trustedUsersProvider);
                    if (_searchController.text.isNotEmpty) {
                      // Show search results
                      return _isSearching
                          ? Center(
                              child: CircularProgressIndicator(
                                color: AppPallete.secondaryDark,
                              ),
                            )
                          : _searchResults.isEmpty
                              ? Center(
                                  child: Text(
                                    'No users found',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _searchResults.length,
                                  itemBuilder: (context, index) {
                                    final user = _searchResults[index];
                                                                         final isAlreadyTrusted = trustedUsersState.trustedUsers
                                         .any((trusted) => trusted.id == user.id);
                                     
                                     return SearchUserTile(
                                       user: user,
                                       isAlreadyTrusted: isAlreadyTrusted,
                                       onAdd: () async {
                                         final success = await ref.read(trustedUsersProvider.notifier).addToTrustedList(user);
                                        if (success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${user.name} added to trusted list'),
                                              backgroundColor: AppPallete.secondaryDark,
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                );
                                         } else {
                       // Show trusted users list
                       return trustedUsersState.trustedUsers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: Colors.white70,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No trusted users yet',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Search for users to add them to your trusted list',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                                                     : ListView.builder(
                               padding: EdgeInsets.symmetric(horizontal: 16),
                               itemCount: trustedUsersState.trustedUsers.length,
                               itemBuilder: (context, index) {
                                 final user = trustedUsersState.trustedUsers[index];
                                return TrustedUserTile(
                                  user: user,
                                                                     onRemove: () async {
                                     final success = await ref.read(trustedUsersProvider.notifier).removeFromTrustedList(user.id);
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${user.name} removed from trusted list'),
                                          backgroundColor: AppPallete.red,
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            );
                    }
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