import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/theme.dart';
import 'package:frontend_weft/features/auth/view/login_page.dart';
import 'package:frontend_weft/features/auth/view/signup_page.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_local_repository.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend_weft/features/navbar/navigation.dart';
import 'package:frontend_weft/features/settings/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  // Load user from local storage on startup
  final user = await container.read(authLocalRepositoryProvider).getUser();
  if (user != null) {
    container.read(authViewModelProvider.notifier).state = user;
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authViewModelProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WEFT',
      theme: DarkAppTheme.darkThemeMode,
      initialRoute: currentUser == null ? '/login' : '/home',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const BottomNavBar(),
        '/settings': (context) =>  const SettingsPage(),
      },
    );
  }
}
