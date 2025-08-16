import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/auth/data/auth_service.dart';
import 'package:frontend_weft/features/auth/model/user_model.dart';
import 'auth_local_repository.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, User?>((
  ref,
) {
  return AuthViewModel(ref);
});

class AuthViewModel extends StateNotifier<User?> {
  final Ref ref;

  AuthViewModel(this.ref) : super(null);

  /// Sign up returns a user and saves it
  Future<bool> signup({
    required String username,
    required String name,
    required String email,
    required String password,
    required String year,
    required String branch,
    required BuildContext context,
  }) async {
    try {
      print("🔐 Starting signup process for: $email");
      
      final user = await ref.read(authServiceProvider).signup({
        "username": username,
        "name": name,
        "email": email,
        "password": password,
        "year": year,
        "branch": branch,
      });

      print("💾 Saving user state and tokens...");
      print("🔑 Access token to save: '${user.accessToken}'");
      print("🔑 Refresh token to save: '${user.refreshToken}'");
      
      state = user;
      
      // Save user and tokens locally (same as login)
      await ref.read(authLocalRepositoryProvider).saveUser(user);
      
      // Only save tokens if they're not empty
      if (user.accessToken.isNotEmpty) {
        await ref
            .read(authLocalRepositoryProvider)
            .saveAccessToken(user.accessToken);
        print("✅ Access token saved successfully");
      } else {
        print("⚠️ Access token is empty, not saving");
      }

      // Save refresh token if available
      if (user.refreshToken != null && user.refreshToken!.isNotEmpty) {
        await ref
            .read(authLocalRepositoryProvider)
            .saveRefreshToken(user.refreshToken!);
        print("✅ Refresh token saved successfully");
      } else {
        print("⚠️ Refresh token is empty or null, not saving");
      }
      
      print("✅ Signup completed successfully!");
      return true;
    } catch (e) {
      print("❌ Signup error: $e");
      _showError(context, e.toString());
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final user = await ref.read(authServiceProvider).login(email, password);
      state = user;

      // Save locally
      await ref.read(authLocalRepositoryProvider).saveUser(user);
      await ref
          .read(authLocalRepositoryProvider)
          .saveAccessToken(user.accessToken);

      // Save refresh token if available
      if (user.refreshToken != null) {
        await ref
            .read(authLocalRepositoryProvider)
            .saveRefreshToken(user.refreshToken!);
      }

      return true;
    } catch (e) {
      _showError(context, "Login failed. Please check credentials.");
      return false;
    }
  }

  Future<void> logoutUser() async {
    await ref.read(authLocalRepositoryProvider).clearUser();
    state = null;
  }

  /// Initialize user state from local storage
  void initializeUser(User user) {
    state = user;
  }

  /// Load user and tokens from local storage on app startup
  Future<void> loadUserFromStorage() async {
    try {
      final user = await ref.read(authLocalRepositoryProvider).getUser();
      final accessToken = await ref.read(authLocalRepositoryProvider).getAccessToken();
      final refreshToken = await ref.read(authLocalRepositoryProvider).getRefreshToken();
      
      print("📱 Loading user from storage...");
      print("👤 User found: ${user != null ? 'Yes' : 'No'}");
      print("🔑 Access token found: ${accessToken != null && accessToken.isNotEmpty ? 'Yes' : 'No'}");
      print("🔑 Refresh token found: ${refreshToken != null && refreshToken.isNotEmpty ? 'Yes' : 'No'}");
      
      if (user != null) {
        // Update user with current tokens from storage
        final updatedUser = User(
          id: user.id,
          name: user.name,
          email: user.email,
          year: user.year,
          branch: user.branch,
          accessToken: accessToken ?? '',
          refreshToken: refreshToken ?? '',
        );
        state = updatedUser;
        print("✅ User loaded successfully with tokens");
      }
    } catch (e) {
      print("❌ Error loading user from storage: $e");
    }
  }

  void _showError(BuildContext context, String error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
  }
}
