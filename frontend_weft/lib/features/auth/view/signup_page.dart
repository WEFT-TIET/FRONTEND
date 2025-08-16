import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../viewmodel/auth_local_repository.dart';
import 'package:frontend_weft/core/utils/auth_debug.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final yearController = TextEditingController();
  final branchController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121221),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'WEFT',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Create your account',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1D2F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildLabel("Username"),
                          _buildInput(usernameController, "Enter your username"),
                          const SizedBox(height: 16),
                          
                          _buildLabel("Full Name"),
                          _buildInput(nameController, "Enter your full name"),
                          const SizedBox(height: 16),
          
                          _buildLabel("College Email"),
                          _buildInput(emailController, "your.name@college.edu"),
                          const SizedBox(height: 16),
          
                          _buildLabel("Password"),
                          _buildInput(passwordController, "Enter your password", obscure: true),
                          const SizedBox(height: 16),
          
                          _buildLabel("Branch"),
                          _buildInput(branchController, "e.g. COE, COPC, ENC"),
                          const SizedBox(height: 16),
          
                          _buildLabel("Year"),
                          _buildInput(yearController, "e.g. 1, 2, 3, 4", obscure: false),
                          const SizedBox(height: 16),
          
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleSignup,
                              style: _buttonStyle(),
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      "Continue",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        "Already have an account? Log in",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      );

  Widget _buildInput(
    TextEditingController controller,
    String hint, {
    bool obscure = false,
  }) =>
      TextFormField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF1D1D2F),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (value) => value!.isEmpty ? 'Required' : null,
      );

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A5FE4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final success = await ref.read(authViewModelProvider.notifier).signup(
          username: usernameController.text.trim(),
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          year: yearController.text.trim(),
          branch: branchController.text.trim(),
          context: context,
        );

    setState(() => isLoading = false);

    if (success) {
      // Debug: Check complete auth state after signup
      await AuthDebugUtils.debugAuthState(ref);
      
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    yearController.dispose();
    branchController.dispose();
    super.dispose();
  }
}
