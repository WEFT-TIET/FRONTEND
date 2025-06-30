import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/providers/current_user_notifier.dart';
import 'package:frontend_weft/core/theme/theme.dart';
import 'package:frontend_weft/features/auth/view/pages/signup_page.dart';
import 'package:frontend_weft/features/navbar/navigation.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
    final container = ProviderContainer();
    runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserNotifierProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WEFT',
      theme: DarkAppTheme.darkThemeMode,
      home: currentUser == null ? const SignupPage() : BottomNavBar(),
    );
  }
}

