import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trusted_user_model.dart';

// State class for trusted users
class TrustedUsersState {
  final List<TrustedUserModel> trustedUsers;
  final bool isGhostModeEnabled;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  TrustedUsersState({
    this.trustedUsers = const [],
    this.isGhostModeEnabled = false,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  TrustedUsersState copyWith({
    List<TrustedUserModel>? trustedUsers,
    bool? isGhostModeEnabled,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return TrustedUsersState(
      trustedUsers: trustedUsers ?? this.trustedUsers,
      isGhostModeEnabled: isGhostModeEnabled ?? this.isGhostModeEnabled,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  List<TrustedUserModel> get filteredTrustedUsers {
    if (searchQuery.isEmpty) {
      return trustedUsers;
    }
    return trustedUsers.where((user) =>
        user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        user.username.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }
}

// StateNotifier for trusted users
class TrustedUsersNotifier extends StateNotifier<TrustedUsersState> {
  TrustedUsersNotifier() : super(TrustedUsersState());

  // Search for users to add to trusted list
  Future<List<TrustedUserModel>> searchUsers(String query) async {
    // Simulate API call - replace with actual API call
    await Future.delayed(Duration(milliseconds: 500));
    
    // Mock data - replace with actual API response
    return [
      TrustedUserModel(
        id: '1',
        name: 'John Doe',
        username: 'johndoe',
        imageUrl: null,
        isOnline: true,
      ),
      TrustedUserModel(
        id: '2',
        name: 'Jane Smith',
        username: 'janesmith',
        imageUrl: null,
        isOnline: false,
      ),
      TrustedUserModel(
        id: '3',
        name: 'Mike Johnson',
        username: 'mikejohnson',
        imageUrl: null,
        isOnline: true,
      ),
    ].where((user) =>
        user.name.toLowerCase().contains(query.toLowerCase()) ||
        user.username.toLowerCase().contains(query.toLowerCase())).toList();
  }

  // Add user to trusted list
  Future<bool> addToTrustedList(TrustedUserModel user) async {
    if (state.trustedUsers.any((trustedUser) => trustedUser.id == user.id)) {
      return false; // User already in trusted list
    }
    
    // Simulate API call
    await Future.delayed(Duration(milliseconds: 300));
    
    state = state.copyWith(
      trustedUsers: [...state.trustedUsers, user],
    );
    return true;
  }

  // Remove user from trusted list
  Future<bool> removeFromTrustedList(String userId) async {
    // Simulate API call
    await Future.delayed(Duration(milliseconds: 300));
    
    final updatedUsers = state.trustedUsers
        .where((user) => user.id != userId)
        .toList();
    
    if (updatedUsers.length != state.trustedUsers.length) {
      state = state.copyWith(trustedUsers: updatedUsers);
      return true;
    }
    return false;
  }

  // Toggle ghost mode
  Future<void> toggleGhostMode() async {
    // Simulate API call
    await Future.delayed(Duration(milliseconds: 200));
    
    state = state.copyWith(
      isGhostModeEnabled: !state.isGhostModeEnabled,
    );
  }

  // Update search query
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Update user location
  void updateUserLocation(String userId, double latitude, double longitude) {
    final updatedUsers = state.trustedUsers.map((user) {
      if (user.id == userId) {
        return user.copyWith(
          latitude: latitude,
          longitude: longitude,
        );
      }
      return user;
    }).toList();
    
    state = state.copyWith(trustedUsers: updatedUsers);
  }

  // Update user ghost mode
  void updateUserGhostMode(String userId, bool isGhostMode) {
    final updatedUsers = state.trustedUsers.map((user) {
      if (user.id == userId) {
        return user.copyWith(isGhostMode: isGhostMode);
      }
      return user;
    }).toList();
    
    state = state.copyWith(trustedUsers: updatedUsers);
  }

  // Load trusted users from API
  Future<void> loadTrustedUsers() async {
    state = state.copyWith(isLoading: true);
    
    // Simulate API call
    await Future.delayed(Duration(milliseconds: 1000));
    
    // Mock data - replace with actual API response
    final trustedUsers = [
      TrustedUserModel(
        id: '1',
        name: 'John Doe',
        username: 'johndoe',
        imageUrl: null,
        isOnline: true,
        latitude: 28.6139,
        longitude: 77.2090,
        isGhostMode: false,
      ),
      TrustedUserModel(
        id: '2',
        name: 'Jane Smith',
        username: 'janesmith',
        imageUrl: null,
        isOnline: false,
        latitude: 28.6140,
        longitude: 77.2091,
        isGhostMode: true,
      ),
    ];
    
    state = state.copyWith(
      trustedUsers: trustedUsers,
      isLoading: false,
    );
  }
}

// Provider for TrustedUsersNotifier
final trustedUsersProvider = StateNotifierProvider<TrustedUsersNotifier, TrustedUsersState>((ref) {
  return TrustedUsersNotifier();
}); 