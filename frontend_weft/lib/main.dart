import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/theme.dart';
import 'package:frontend_weft/features/auth/view/welcome_page.dart';
import 'package:frontend_weft/features/auth/view/login_page.dart';
import 'package:frontend_weft/features/auth/view/signup_page.dart';
import 'package:frontend_weft/features/auth/view/signup_initial_page.dart';
import 'package:frontend_weft/features/auth/view/signup_username_page.dart';
import 'package:frontend_weft/features/auth/view/signup_profile_page.dart';
import 'package:frontend_weft/features/auth/view/forgot_password_page.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_local_repository.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend_weft/features/navbar/navigation.dart';
import 'package:frontend_weft/features/settings/pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  // Load user from local storage on startup
  final user = await container.read(authLocalRepositoryProvider).getUser();
  if (user != null) {
    container.read(authViewModelProvider.notifier).initializeUser(user);
  }

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
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
      initialRoute: currentUser == null ? '/welcome' : '/home',
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/signup-initial': (context) => const SignupInitialPage(),
        '/signup-username': (context) => const SignupUsernamePage(),
        '/signup-profile': (context) => const SignupProfilePage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/home': (context) => const BottomNavBar(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}