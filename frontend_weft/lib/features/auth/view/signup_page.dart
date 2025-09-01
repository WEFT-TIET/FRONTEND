import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'dart:async';

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
  
  // Username availability checking
  Timer? _usernameDebounceTimer;
  String _usernameStatus = ''; // 'available', 'unavailable', 'checking', 'error'
  String _usernameMessage = '';
  
  // Simulated taken usernames for demo purposes
  final Set<String> _takenUsernames = {
    'admin', 'user', 'test', 'demo', 'sample', 'john', 'jane', 'weft', 'tiet',
    'student', 'college', 'university', 'professor', 'teacher', 'staff'
  };

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_onUsernameChanged);
  }

  void _onUsernameChanged() {
    final username = usernameController.text.trim().toLowerCase();
    
    // Cancel previous timer
    _usernameDebounceTimer?.cancel();
    
    if (username.isEmpty) {
      setState(() {
        _usernameStatus = '';
        _usernameMessage = '';
      });
      return;
    }
    
    // Start new timer with 500ms delay to simulate real-time checking
    _usernameDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _checkUsernameAvailability(username);
    });
  }

  void _checkUsernameAvailability(String username) {
    setState(() {
      _usernameStatus = 'checking';
      _usernameMessage = 'Checking availability...';
    });

    // Simulate API call delay
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      
      String status;
      String message;
      
      if (username.length < 3) {
        status = 'error';
        message = 'Username must be at least 3 characters';
      } else if (username.length > 20) {
        status = 'error';
        message = 'Username must be less than 20 characters';
      } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
        status = 'error';
        message = 'Username can only contain letters, numbers, and underscores';
      } else if (_takenUsernames.contains(username)) {
        status = 'unavailable';
        message = 'Username is already taken';
      } else {
        status = 'available';
        message = 'Username is available!';
      }
      
      setState(() {
        _usernameStatus = status;
        _usernameMessage = message;
      });
    });
  }

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
                          _buildUsernameInput(),
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
                          _buildInput(branchController, "e.g. COPC, COE, ECE, ENC"),
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

  Widget _buildUsernameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: usernameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter your username",
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1D1D2F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _getBorderColor(),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _getBorderColor(),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _getBorderColor(),
                width: 2.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: _getUsernameStatusIcon(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Username is required';
            }
            if (_usernameStatus == 'unavailable') {
              return 'Username is not available';
            }
            if (_usernameStatus == 'error') {
              return _usernameMessage;
            }
            return null;
          },
        ),
        if (_usernameMessage.isNotEmpty) ...[
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getStatusColor().withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 16,
                  color: _getStatusColor(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _usernameMessage,
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _getBorderColor() {
    switch (_usernameStatus) {
      case 'available':
        return Colors.green;
      case 'unavailable':
        return Colors.red;
      case 'error':
        return Colors.red;
      case 'checking':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget? _getUsernameStatusIcon() {
    switch (_usernameStatus) {
      case 'checking':
        return Container(
          padding: const EdgeInsets.all(12),
          child: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        );
      case 'available':
        return const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.check_circle, color: Colors.green, size: 20),
        );
      case 'unavailable':
        return const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.cancel, color: Colors.red, size: 20),
        );
      case 'error':
        return const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.error, color: Colors.red, size: 20),
        );
      default:
        return null;
    }
  }

  IconData _getStatusIcon() {
    switch (_usernameStatus) {
      case 'available':
        return Icons.check_circle;
      case 'unavailable':
        return Icons.cancel;
      case 'checking':
        return Icons.hourglass_empty;
      case 'error':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor() {
    switch (_usernameStatus) {
      case 'available':
        return Colors.green;
      case 'unavailable':
        return Colors.red;
      case 'checking':
        return Colors.blue;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Convert single digit year (1,2,3,4) to full year (2024,2025,2026,2027)
  String _convertYearToFullYear(String singleDigitYear) {
    switch (singleDigitYear) {
      case '1':
        return '2024'; // 1st year students (current batch)
      case '2':
        return '2023'; // 2nd year students
      case '3':
        return '2022'; // 3rd year students
      case '4':
        return '2021'; // 4th year students
      default:
        return '2024'; // Default to 1st year
    }
  }

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A5FE4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // Convert single digit year to 4-digit year
    String convertedYear = _convertYearToFullYear(yearController.text.trim());

    // Prepare registration data
    final registrationData = {
      "username": usernameController.text.trim(),
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "year": convertedYear,
      "branch": branchController.text.trim(),
    };

    final success = await ref.read(authViewModelProvider.notifier).initiateRegistration(
          username: registrationData["username"]!,
          name: registrationData["name"]!,
          email: registrationData["email"]!,
          password: registrationData["password"]!,
          year: registrationData["year"]!,
          branch: registrationData["branch"]!,
          context: context,
        );

    setState(() => isLoading = false);

    if (success && mounted) {
      // Navigate to OTP verification page
      Navigator.pushNamed(
        context,
        '/otp-verification',
        arguments: {
          'email': registrationData["email"]!,
        },
      );
    }
  }

  @override
  void dispose() {
    _usernameDebounceTimer?.cancel();
    usernameController.removeListener(_onUsernameChanged);
    usernameController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    yearController.dispose();
    branchController.dispose();
    super.dispose();
  }
}
