import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_local_repository.g.dart';

class AuthLocalRepository {
  late SharedPreferences _sharedPreferences;

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  void setToken(String? token) {
    if (token != null) {
      _sharedPreferences.setString('x-auth-token', token);
    }
  }

  String? getToken() {
    return _sharedPreferences.getString('x-auth-token');
  }

  void clearToken() {
    _sharedPreferences.remove('x-auth-token');
  }
}

@Riverpod(keepAlive: true)
Future<AuthLocalRepository> authLocalRepository(AuthLocalRepositoryRef ref) async {
  final repo = AuthLocalRepository();
  await repo.init();
  return repo;
}
