import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/auth_viewmodel.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final classIdController = TextEditingController();
  final yearController = TextEditingController();
  final branchController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121221),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Add your details to connect with your peers',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),

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
                _buildInput(yearController, "e.g. 2025"),
                const SizedBox(height: 16),

                _buildLabel("Class ID"),
                _buildInput(classIdController, "e.g. COE123"),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleSignup,
                    style: _buttonStyle(),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Continue"),
                  ),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text("Already have an account? Log in",
                      style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      );

  Widget _buildInput(TextEditingController controller, String hint,
          {bool obscure = false}) =>
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
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (value) => value!.isEmpty ? 'Required' : null,
      );

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A5FE4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  void _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final success = await ref.read(authViewModelProvider.notifier).signup(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          year: yearController.text.trim(),
          classId: classIdController.text.trim(),
          branch: branchController.text.trim(),
          context: context,
        );

    setState(() => isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
