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

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final namecontroller = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    namecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      authViewmodelProvider.select((val) => val?.isLoading == true),
    );

    ref.listen(authViewmodelProvider, (_, next) {
      next?.when(
        data: (data) {
          showSnackBar(context, 'Account created successfully!');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        error: (error, st) {
          showSnackBar(context, error.toString());
        },
        loading: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(),
      body:
          isLoading
              ? LoadingIndicator()
              : Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sign Up.",
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomField(hintText: "Name", controller: namecontroller),
                        const SizedBox(height: 10),
                        CustomField(
                          hintText: "Email",
                          controller: emailcontroller,
                        ),
                        const SizedBox(height: 10),
                        CustomField(
                          hintText: "Password",
                          controller: passwordcontroller,
                          isPassword: true,
                        ),
                        const SizedBox(height: 20),
                        AuthButton(
                          buttonText: 'Sign Up',
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              await ref
                                  .read(authViewmodelProvider.notifier)
                                  .signup(
                                    name: namecontroller.text,
                                    email: emailcontroller.text,
                                    password: passwordcontroller.text,
                                  );
                            } else {
                              showSnackBar(context, "Missing fields");
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ));
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: Theme.of(context).textTheme.titleMedium,
                              children: [
                                TextSpan(
                                  text: "Login",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
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
