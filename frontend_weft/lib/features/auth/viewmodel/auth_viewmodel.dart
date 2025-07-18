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
    required String name,
    required String email,
    required String password,
    required String year,
    required String classId,
    required String branch,
    required BuildContext context,
  }) async {
    try {
      final user = await ref.read(authServiceProvider).signup({
        "name": name,
        "email": email,
        "password": password,
        "year": year,
        "class_id": classId,
        "branch": branch,
      });

      state = user;
      await ref.read(authLocalRepositoryProvider).saveUser(user);
      return true;
    } catch (e) {
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

  void _showError(BuildContext context, String error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
  }
}
