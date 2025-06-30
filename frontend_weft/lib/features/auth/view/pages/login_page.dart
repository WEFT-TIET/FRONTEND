import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/core/utils.dart';
import 'package:frontend_weft/core/widgets/loader.dart';
import 'package:frontend_weft/features/auth/repositories/auth_local_repository.dart';
import 'package:frontend_weft/features/auth/view/widgets/auth_button.dart';
import 'package:frontend_weft/core/widgets/custom_field.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:frontend_weft/features/auth/view/pages/signup_page.dart';
import 'package:frontend_weft/features/navbar/navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const LoginPage());
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!formKey.currentState!.validate()) {
      showSnackBar(context, "Missing fields");
      return;
    }

    setState(() => isLoading = true);

    final authVM = ref.read(authViewModelProvider);
    await authVM.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    final repo = await ref.read(authLocalRepositoryProvider.future);
    final token = repo.getToken();

    setState(() => isLoading = false);

    if (token != null && token.isNotEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
        (_) => false,
      );
    } else {
      showSnackBar(context, "Login failed. Please check credentials.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const LoadingIndicator()
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Login.",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomField(
                        hintText: "Email",
                        controller: emailController,
                      ),
                      const SizedBox(height: 10),
                      CustomField(
                        hintText: "Password",
                        controller: passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 20),
                      AuthButton(buttonText: 'Login', onTap: _handleLogin),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Don\'t have an account? ',
                            style: Theme.of(context).textTheme.titleMedium,
                            children: [
                              TextSpan(
                                text: "Sign Up",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppPallete.gradient2,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
