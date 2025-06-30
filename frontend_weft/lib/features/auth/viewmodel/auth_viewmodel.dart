import 'package:frontend_weft/core/providers/current_user_notifier.dart';
import 'package:frontend_weft/features/auth/model/user_model.dart';
import 'package:frontend_weft/features/auth/repositories/auth_local_repository.dart';
import 'package:frontend_weft/features/auth/repositories/auth_remote_repository.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewmodel extends _$AuthViewmodel {
  late AuthRemoteRepository _authRemoteRepository;
  late AuthLocalRepository _authLocalRepository;
  late CurrentUserNotifier _currentUserNotifier;

  @override
  AsyncValue<UserModel>? build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    _currentUserNotifier = ref.watch(currentUserNotifierProvider.notifier);
    return null;
  }

  Future<void> initSharedPreferences() async {
    await _authLocalRepository.init();
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final response = await _authRemoteRepository.signup(
      name: name,
      email: email,
      password: password,
    );

    response.match(
      (l) => state = AsyncValue.error(l, StackTrace.current),
      (r) => state = AsyncValue.data(r),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    final response = await _authRemoteRepository.login(
      email: email,
      password: password,
    );

    response.match(
      (l) => state = AsyncValue.error(l, StackTrace.current),
      (r) => _loginSuccess(r),
    );
  }

  AsyncValue<UserModel>? _loginSuccess(UserModel user) {
    _authLocalRepository.setToken(user.token);
    _currentUserNotifier.addUser(user);
    return state = AsyncValue.data(user);
  }

  Future<UserModel?> getData() async {
    state = const AsyncValue.loading();
    final token = _authLocalRepository.getToken();
    if (token != null) {
      final response = await _authRemoteRepository.getUserData(token);
      final result = response.match(
        (l) => state = AsyncValue.error(l, StackTrace.current),
        (r) => _getDataSuccess(r),
      );
      return result.value;
    }
    return null;
  }

  AsyncValue<UserModel> _getDataSuccess(UserModel user) {
    _currentUserNotifier.addUser(user);
    return state = AsyncValue.data(user);
  }
}
