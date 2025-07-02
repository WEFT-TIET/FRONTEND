import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/auth/data/auth_service.dart';
import 'package:frontend_weft/features/auth/model/user_model.dart';
import 'auth_local_repository.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, User?>((ref) {
  return AuthViewModel(ref);
});

class AuthViewModel extends StateNotifier<User?> {
  final Ref ref;
  AuthViewModel(this.ref) : super(null);

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
      await ref.read(authLocalRepositoryProvider).saveUser(user);
      return true;
    } catch (e) {
      _showError(context, e.toString());
      return false;
    }
  }

  /// ✅ FIXED: No need to pass `ref` when it's already in scope
  Future<void> logoutUser() async {
    await ref.read(authLocalRepositoryProvider).clearUser();
    state = null;
  }

  void _showError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.red),
    );
  }
}
