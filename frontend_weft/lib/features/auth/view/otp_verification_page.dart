import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/auth_viewmodel.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  final String email;
  
  const OtpVerificationPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool isLoading = false;
  bool isResending = false;

  @override
  void initState() {
    super.initState();
    // Auto focus on first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'We sent a verification code to\n${widget.email}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => _buildOtpField(index)),
              ),
              
              const SizedBox(height: 40),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleVerifyOtp,
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
                          "Verify",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Resend Code
              Center(
                child: TextButton(
                  onPressed: isResending ? null : _handleResendCode,
                  child: isResending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey,
                          ),
                        )
                      : const Text(
                          "Didn't receive code? Resend",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
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
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Move to next field
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // Last field, remove focus
              _focusNodes[index].unfocus();
            }
          } else {
            // Move to previous field if current is empty
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
        onTap: () {
          // Clear field when tapped
          _controllers[index].clear();
        },
      ),
    );
  }

  String _getOtpCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  bool _isOtpComplete() {
    return _getOtpCode().length == 6;
  }

  Future<void> _handleVerifyOtp() async {
    if (!_isOtpComplete()) {
      _showError("Please enter the complete 6-digit code");
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await ref.read(authViewModelProvider.notifier).verifyOtp(
        email: widget.email,
        otp: _getOtpCode(),
        context: context,
      );

      if (success && mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      _showError("Verification failed. Please try again.");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleResendCode() async {
    setState(() => isResending = true);

    try {
      await ref.read(authViewModelProvider.notifier).resendOtp(
        email: widget.email,
        context: context,
      );
      
      _showSuccess("Verification code sent again");
      
      // Clear current OTP fields
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      
    } catch (e) {
      _showError("Failed to resend code. Please try again.");
    } finally {
      if (mounted) {
        setState(() => isResending = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}