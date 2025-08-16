 import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/auth_viewmodel.dart';

class SignupProfilePage extends ConsumerStatefulWidget {
  const SignupProfilePage({super.key});

  @override
  ConsumerState<SignupProfilePage> createState() => _SignupProfilePageState();
}

class _SignupProfilePageState extends ConsumerState<SignupProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final branchController = TextEditingController();
  final yearController = TextEditingController();
  bool isLoading = false;
  Map<String, String>? signupData;

  final List<String> branches = [
    'COE', 'COPC', 'ENC', 'EIC', 'ECE', 'ME', 'CE', 'CHE', 'BT', 'FT', 'TT'
  ];
  
  final List<String> years = ['2024', '2', '3', '4'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the signup data passed from previous screen
    signupData = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121221),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Progress indicator
                _buildProgressIndicator(currentStep: 3, totalSteps: 3),
                
                const SizedBox(height: 30),
                
                // Title
                const Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                const Text(
                  'Tell us about yourself to complete registration',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Full Name field
                _buildLabel("Full Name"),
                _buildInput(
                  nameController,
                  "Enter your full name",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Full name is required';
                    }
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Branch dropdown
                _buildLabel("Branch"),
                _buildDropdown(
                  value: branchController.text.isEmpty ? null : branchController.text,
                  hint: "Select your branch",
                  items: branches,
                  onChanged: (value) {
                    setState(() {
                      branchController.text = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your branch';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Year dropdown
                _buildLabel("Year"),
                _buildDropdown(
                  value: yearController.text.isEmpty ? null : yearController.text,
                  hint: "Select your year",
                  items: years,
                  onChanged: (value) {
                    setState(() {
                      yearController.text = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your year';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Complete Registration Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleCompleteRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A5FE4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Complete Registration",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _buildProgressIndicator({required int currentStep, required int totalSteps}) {
    return Row(
      children: List.generate(
        totalSteps,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: index < currentStep ? const Color(0xFF4A5FE4) : Colors.grey.shade700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String hint, {
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A5FE4), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
    required String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A5FE4), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dropdownColor: const Color(0xFF1D1D2F),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  void _handleCompleteRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    if (signupData != null) {
      final success = await ref.read(authViewModelProvider.notifier).signup(
        username: signupData!['username']!,
        name: nameController.text.trim(),
        email: signupData!['email']!,
        password: signupData!['password']!,
        year: yearController.text.trim(),
        branch: branchController.text.trim(),
        context: context,
      );

      setState(() => isLoading = false);

      if (success && mounted) {
        // Navigate to home and clear the stack
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    } else {
      setState(() => isLoading = false);
      // Show error if signup data is missing
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration data is missing. Please start again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    branchController.dispose();
    yearController.dispose();
    super.dispose();
  }
}
