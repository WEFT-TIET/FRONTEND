import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/profile/models/user_model.dart';
import 'package:frontend_weft/features/profile/services/profile_api_service.dart';
import 'package:frontend_weft/features/profile/widgets/profile_dialogs.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final UserModel user;
  
  const EditProfilePage({super.key, required this.user});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  bool _isLoading = false;
  String? _errorMessage;

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _yearController;
  late TextEditingController _branchController;
  late TextEditingController _instagramController;

  // Add your Cloudinary details here
  static const String _cloudName = 'CLOUDINARY_CLOUD_NAME';
  static const String _uploadPreset = 'CLOUDINARY_UPLOAD_PRESET';

  String? _updatedImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.user.name);
    _usernameController = TextEditingController(text: widget.user.username);
    _yearController = TextEditingController(text: widget.user.year);
    _branchController = TextEditingController(text: widget.user.branch);
    _instagramController = TextEditingController(text: widget.user.instagramId ?? '');
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: AppPallete.transperantColor,
        appBar: AppBar(
          backgroundColor: AppPallete.transperantColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: AppPallete.textPrimaryDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: AppPallete.textPrimaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileImageSection(),
                  const SizedBox(height: 24),
                  _buildEditForm(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppPallete.textPrimaryDark),
                  ),
                ),
              ),
            if (_errorMessage != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.red.withValues(alpha: 0.9),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF2A2D5A).withValues(alpha: 0.8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImagePicker,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(color: const Color(0xFF6366F1), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: Stack(
                  children: [
                    if (_updatedImageUrl != null)
                      Image.network(
                        _updatedImageUrl!,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                      )
                    else if (widget.user.imageUrl != null && widget.user.imageUrl!.startsWith('http'))
                      Image.network(
                        widget.user.imageUrl!,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                      )
                    else
                      Image.asset(
                        widget.user.imageUrl ?? 'lib/core/assets/profile_photo.jpeg',
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to change photo',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6366F1).withValues(alpha: 0.3), const Color(0xFF8B5CF6).withValues(alpha: 0.3)],
        ),
      ),
      child: Icon(
        Icons.person,
        color: Colors.white.withValues(alpha: 0.8),
        size: 50,
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF2A2D5A).withValues(alpha: 0.8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormField('Name', _nameController, Icons.person),
          const SizedBox(height: 16),
          _buildFormField('Username', _usernameController, Icons.alternate_email, prefix: '@'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildFormField('Year', _yearController, Icons.school)),
              const SizedBox(width: 12),
              Expanded(child: _buildFormField('Branch', _branchController, Icons.engineering)),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormField('Instagram', _instagramController, Icons.camera_alt, prefix: '@'),
        ],
      ),
    );
  }

  Widget _buildFormField(
    String label, 
    TextEditingController controller, 
    IconData icon, {
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D3A).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
              prefixText: prefix,
              prefixStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedUser = widget.user.copyWith(
        name: _nameController.text,
        username: _usernameController.text,
        year: _yearController.text,
        branch: _branchController.text,
        instagramId: _instagramController.text.isEmpty ? null : _instagramController.text,
        imageUrl: _updatedImageUrl ?? widget.user.imageUrl,
        skills: widget.user.skills, // Preserve existing skills
      );

      final api = ref.read(profileApiServiceProvider);
      final success = await api.updateUserProfile(updatedUser.toJson());

      if (success) {
        HapticFeedback.lightImpact();
        ProfileDialogs.showSnackBar(context, 'Profile updated successfully!');
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        setState(() => _errorMessage = 'Failed to update profile');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Update failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showImagePicker() async {
    HapticFeedback.selectionClick();
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _uploadProfileImageToCloudinary(pickedFile.path);
    }
  }

  Future<void> _uploadProfileImageToCloudinary(String filePath) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          filePath,
          resourceType: CloudinaryResourceType.Image,
          publicId: 'profile_pictures/user_${widget.user.username}',
        ),
      );

      setState(() {
        _updatedImageUrl = response.secureUrl;
      });

      ProfileDialogs.showSnackBar(context, 'Profile image updated!');
    } catch (e) {
      setState(() => _errorMessage = 'Image upload failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _yearController.dispose();
    _branchController.dispose();
    _instagramController.dispose();
    super.dispose();
  }
}
