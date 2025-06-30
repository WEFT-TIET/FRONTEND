import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/core/utils.dart';
import 'package:frontend_weft/core/widgets/loader.dart';
import 'package:frontend_weft/features/auth/view/pages/login_page.dart';
import 'package:frontend_weft/features/auth/view/widgets/auth_button.dart';
import 'package:frontend_weft/core/widgets/custom_field.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  static route() => MaterialPageRoute(builder: (context) => const SignupPage());

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final yearController = TextEditingController();
  final branchController = TextEditingController();
  final sectionController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  void dispose() {
    yearController.dispose();
    branchController.dispose();
    sectionController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!formKey.currentState!.validate()) {
      showSnackBar(context, "Missing fields");
      return;
    }

    setState(() => isLoading = true);

    final authVM = ref.read(authViewModelProvider);
    final result = await authVM.signup(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      year: yearController.text.trim(),
      branch: branchController.text.trim(),
      class_id: sectionController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result) {
      showSnackBar(context, 'Account created successfully!');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      showSnackBar(context, 'Signup failed. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? const LoadingIndicator()
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Sign Up.",
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomField(hintText: "Name", controller: nameController),
                        const SizedBox(height: 10),
                        CustomField(hintText: "Email", controller: emailController),
                        const SizedBox(height: 10),
                        CustomField(hintText: "Year", controller: yearController),
                        const SizedBox(height: 10),
                        CustomField(hintText: "Branch", controller: branchController),
                        const SizedBox(height: 10),
                        CustomField(hintText: "Section", controller: sectionController),
                        const SizedBox(height: 10),
                        CustomField(
                          hintText: "Password",
                          controller: passwordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 20),
                        AuthButton(
                          buttonText: 'Sign Up',
                          onTap: _handleSignup,
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              LoginPage.route(),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: Theme.of(context).textTheme.titleMedium,
                              children: [
                                TextSpan(
                                  text: "Login",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
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
            ),
    );
  }
}
