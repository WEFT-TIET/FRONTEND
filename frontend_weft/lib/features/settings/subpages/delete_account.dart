import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/settings/viewmodels/delete_account_viewmodel.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_viewmodel.dart';

class DeleteAccountPage extends ConsumerStatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  ConsumerState<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends ConsumerState<DeleteAccountPage> {
  final TextEditingController _confirmationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _confirmationMatches = false;
  final String _requiredText = 'DELETE';
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_checkConfirmation);
    
    // Pre-fill email field with current user's email
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(authViewModelProvider);
      if (currentUser != null && currentUser.email.isNotEmpty) {
        _emailController.text = currentUser.email;
        print("📧 Pre-filled email: ${currentUser.email}");
      }
    });
    
    // Listen to viewmodel state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<DeleteAccountState>(deleteAccountViewModelProvider, (previous, next) {
        if (next.errorMessage != null) {
          _showSnackBar(next.errorMessage!, isError: true);
        } else if (next.isSuccess && !_isNavigating) {
          _isNavigating = true;
          _showSnackBar('Account deleted successfully. You will be logged out shortly.');
          _handleSuccessfulDeletion();
        }
      });
    });
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkConfirmation() {
    setState(() {
      _confirmationMatches = _confirmationController.text.trim() == _requiredText;
    });
  }

  Future<void> _deleteAccount() async {
    if (!_confirmationMatches || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please complete all fields correctly', isError: true);
      return;
    }

    // Show final confirmation dialog
    final confirmed = await _showFinalConfirmationDialog();
    if (!confirmed) return;

    // Call the viewmodel to delete account
    await ref.read(deleteAccountViewModelProvider.notifier)
        .deleteAccount(_emailController.text.trim(), _passwordController.text.trim());
  }

  Future<void> _handleSuccessfulDeletion() async {
    try {
      print("🔄 Starting post-deletion cleanup and navigation");
      
      // Wait a moment for the success message to be visible
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      
      print("🔄 Clearing user state after successful account deletion");
      // Clear the user state from auth viewmodel
      await ref.read(authViewModelProvider.notifier).logoutUser();
      
      // Wait for state to update
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // Debug: Check if user state is actually cleared
      final userAfterLogout = ref.read(authViewModelProvider);
      print("👤 User state after logout: ${userAfterLogout == null ? 'null (logged out)' : 'still logged in'}");
      
      print("🔄 Attempting navigation to login page");
      print("🔄 Current route: ${ModalRoute.of(context)?.settings.name}");
      
      // Use post-frame callback to ensure navigation happens after all state updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          try {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            print("✅ Navigation completed successfully");
          } catch (e) {
            print("❌ Navigation error: $e");
            // Try alternative navigation
            try {
              Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
              print("✅ Alternative navigation to welcome completed");
            } catch (e2) {
              print("❌ Alternative navigation failed: $e2");
            }
          }
        }
      });
      
    } catch (e) {
      print("❌ Error during post-deletion process: $e");
      if (mounted) {
        _showSnackBar('Account deleted successfully. Tap here to go to login.', isError: false);
        // Show a dialog with manual navigation option
        _showManualNavigationDialog();
      }
    }
  }

  Future<bool> _showFinalConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppPallete.glassWhite20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppPallete.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Final Warning',
                style: TextStyle(
                  color: AppPallete.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'This action cannot be undone. Your account and all associated data will be permanently deleted.',
            style: TextStyle(
              color: AppPallete.textPrimaryDark,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppPallete.textPrimaryDark),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppPallete.red, Color(0xFFD32F2F)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete Forever',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppPallete.red : AppPallete.gradient2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showManualNavigationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppPallete.glassWhite20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Account Deleted Successfully',
            style: TextStyle(
              color: AppPallete.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Your account has been deleted successfully. Please tap the button below to go to the login page.',
            style: TextStyle(
              color: AppPallete.textPrimaryDark,
              height: 1.5,
            ),
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppPallete.gradient1, AppPallete.gradient2],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: const Text(
                  'Go to Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deleteAccountState = ref.watch(deleteAccountViewModelProvider);
    final isLoading = deleteAccountState.isLoading;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPallete.gradient1,
            AppPallete.gradient2,
            AppPallete.gradient3,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppPallete.glassWhite10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppPallete.glassWhite20, width: 0.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: const Text(
            'Delete Account',
            style: TextStyle(
              color: AppPallete.textPrimaryDark,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppPallete.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPallete.red.withOpacity(0.3), width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.dangerous,
                          color: AppPallete.red,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Danger Zone',
                          style: TextStyle(
                            color: AppPallete.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Deleting your account will permanently remove all your data, including posts, comments, likes, and personal information. This action cannot be undone.',
                      style: TextStyle(
                        color: AppPallete.textPrimaryDark,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // What will be deleted section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppPallete.glassWhite05,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPallete.glassWhite20, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What will be deleted:',
                      style: TextStyle(
                        color: AppPallete.textPrimaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDeletionItem(Icons.post_add, 'All your posts and wefts'),
                    _buildDeletionItem(Icons.chat_bubble, 'All your comments'),
                    _buildDeletionItem(Icons.star, 'All your likes and reactions'),
                    _buildDeletionItem(Icons.person, 'Your profile information'),
                    _buildDeletionItem(Icons.settings, 'All account settings'),
                    _buildDeletionItem(Icons.block, 'Your block list'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Confirmation Section
              const Text(
                'Confirmation Required',
                style: TextStyle(
                  color: AppPallete.textPrimaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Type "$_requiredText" to confirm account deletion:',
                style: TextStyle(
                  color: AppPallete.whiteColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppPallete.glassWhite05,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _confirmationMatches 
                        ? Colors.green.withOpacity(0.5)
                        : AppPallete.glassWhite20, 
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _confirmationController,
                  style: const TextStyle(color: AppPallete.textPrimaryDark),
                  decoration: InputDecoration(
                    hintText: 'Type "$_requiredText"',
                    hintStyle: TextStyle(color: AppPallete.whiteColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    suffixIcon: _confirmationMatches
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Email Confirmation
              const Text(
                'Confirm your email address:',
                style: TextStyle(
                  color: AppPallete.textPrimaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppPallete.glassWhite05,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppPallete.glassWhite20, width: 1),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppPallete.textPrimaryDark),
                  decoration: InputDecoration(
                    hintText: 'Your email address',
                    hintStyle: TextStyle(color: AppPallete.whiteColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Password Confirmation
              const Text(
                'Enter your password to proceed:',
                style: TextStyle(
                  color: AppPallete.textPrimaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppPallete.glassWhite05,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppPallete.glassWhite20, width: 1),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  style: const TextStyle(color: AppPallete.textPrimaryDark),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(color: AppPallete.whiteColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: AppPallete.whiteColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Delete Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _confirmationMatches && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty
                        ? const LinearGradient(
                            colors: [AppPallete.red, Color(0xFFD32F2F)],
                          )
                        : null,
                    color: _confirmationMatches && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty
                        ? null
                        : AppPallete.greyColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(27),
                  ),
                  child: ElevatedButton(
                    onPressed: (_confirmationMatches && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty && !isLoading)
                        ? _deleteAccount
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Delete My Account Forever',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: AppPallete.glassWhite10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                      side: BorderSide(color: AppPallete.glassWhite20, width: 1),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppPallete.textPrimaryDark,
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
    );
  }

  Widget _buildDeletionItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppPallete.red.withOpacity(0.8),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppPallete.textPrimaryDark,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}