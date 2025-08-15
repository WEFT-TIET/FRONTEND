import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/core/mixins/keyboard_dismissal_mixin.dart';
import 'package:frontend_weft/features/post/viewmodel/post_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage>
    with TickerProviderStateMixin, KeyboardDismissalMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<TextEditingController> _pollControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  
  late AnimationController _animationController;
  
  List<File> _selectedImages = [];
  bool _isPollMode = false;
  bool _isLoading = false;
  PostType _selectedPostType = PostType.regular;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    for (var controller in _pollControllers) {
      controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (images != null && images.isNotEmpty) {
        setState(() {
          _selectedImages = images.take(4).map((image) => File(image.path)).toList();
        });
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      _showSnackBar('Error picking images: $e', isError: true);
    }
  }

  Future<void> _pickCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      _showSnackBar('Error taking photo: $e', isError: true);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    HapticFeedback.mediumImpact();
  }

  void _togglePostType(PostType type) {
    setState(() {
      _selectedPostType = type;
      _isPollMode = type == PostType.poll;
    });
    HapticFeedback.selectionClick();
    
    if (_isPollMode) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppPallete.red : AppPallete.gradient2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      _showSnackBar('Title and content cannot be empty!', isError: true);
      return;
    }

    if (_isPollMode) {
      bool hasEmptyOption = false;
      for (int i = 0; i < _pollControllers.length; i++) {
        if (_pollControllers[i].text.trim().isEmpty) {
          hasEmptyOption = true;
          break;
        }
      }
      if (hasEmptyOption || _pollControllers.length < 2) {
        _showSnackBar('Please fill at least 2 poll options!', isError: true);
        return;
      }
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final success = await ref
          .read(postViewModelProvider.notifier)
          .createPost(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
          );

      if (success) {
        _showSnackBar('${_isPollMode ? "Poll" : "Post"} created successfully! 🎉');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.of(context).pop();
      } else {
        _showSnackBar('Failed to create ${_isPollMode ? "poll" : "post"}. Try again!', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return addKeyboardDismissal(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
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
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildPostTypeSelector(),
                      const SizedBox(height: 24),
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      _buildContentField(),
                      const SizedBox(height: 16),
                      _buildImageSection(),
                      const SizedBox(height: 16),
                      _buildPollSection(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        'Create ${_isPollMode ? "Poll" : "Post"}',
        style: GoogleFonts.oswald(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppPallete.gradient1.withValues(alpha: 0.3),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTypeOption(PostType.regular, Icons.article, 'Post')),
          const SizedBox(width: 8),
          Expanded(child: _buildTypeOption(PostType.poll, Icons.poll, 'Poll')),
        ],
      ),
    );
  }

  Widget _buildTypeOption(PostType type, IconData icon, String label) {
    final isSelected = _selectedPostType == type;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _togglePostType(type),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _titleController,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: _isPollMode ? 'What\'s your question?' : 'Give your post a title...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(20),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isPollMode ? Icons.quiz : Icons.title,
              color: const Color(0xFF6366F1),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentField() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _contentController,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
        ),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: _isPollMode 
              ? 'Add some context to your poll...' 
              : 'Share your thoughts, experiences, or ask the community...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedImages.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _selectedImages.length == 1
                  ? _buildSingleImage()
                  : _buildImageGrid(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(child: _buildImageButton(Icons.photo_library, 'Gallery', _pickImages)),
            const SizedBox(width: 12),
            Expanded(child: _buildImageButton(Icons.camera_alt, 'Camera', _pickCamera)),
          ],
        ),
      ],
    );
  }

  Widget _buildSingleImage() {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(_selectedImages[0]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _buildRemoveButton(() => _removeImage(0)),
        ),
      ],
    );
  }

  Widget _buildImageGrid() {
    return SizedBox(
      height: 200,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _selectedImages.length > 2 ? 2 : _selectedImages.length,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(_selectedImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: _buildRemoveButton(() => _removeImage(index)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRemoveButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Color(0xFFEF4444),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildImageButton(IconData icon, String label, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFF6366F1), size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPollSection() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _isPollMode
          ? SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              )),
              child: FadeTransition(
                opacity: _animationController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Poll Options',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_pollControllers.length < 6)
                          GestureDetector(
                            onTap: _addPollOption,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, color: const Color(0xFF6366F1), size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Add Option',
                                    style: TextStyle(
                                      color: const Color(0xFF6366F1),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_pollControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPollOption(
                          _pollControllers[index], 
                          'Option ${index + 1}', 
                          _getPollIcon(index),
                          index,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  void _addPollOption() {
    if (_pollControllers.length < 6) {
      setState(() {
        _pollControllers.add(TextEditingController());
      });
      HapticFeedback.lightImpact();
    }
  }

  void _removePollOption(int index) {
    if (_pollControllers.length > 2) {
      setState(() {
        _pollControllers[index].dispose();
        _pollControllers.removeAt(index);
      });
      HapticFeedback.mediumImpact();
    }
  }

  IconData _getPollIcon(int index) {
    switch (index) {
      case 0: return Icons.looks_one;
      case 1: return Icons.looks_two;
      case 2: return Icons.looks_3;
      case 3: return Icons.looks_4;
      case 4: return Icons.looks_5;
      case 5: return Icons.looks_6;
      default: return Icons.radio_button_unchecked;
    }
  }

  Widget _buildPollOption(TextEditingController controller, String hint, IconData icon, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6366F1),
              size: 16,
            ),
          ),
          suffixIcon: _pollControllers.length > 2
              ? IconButton(
                  icon: Icon(
                    Icons.remove_circle,
                    color: const Color(0xFFEF4444).withValues(alpha: 0.8),
                    size: 20,
                  ),
                  onPressed: () => _removePollOption(index),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildSecondaryButton(
            'Clear All',
            Icons.clear_all,
            () {
              _titleController.clear();
              _contentController.clear();
              for (var controller in _pollControllers) {
                controller.clear();
              }
              setState(() {
                _selectedImages.clear();
                _selectedPostType = PostType.regular;
                _isPollMode = false;
                // Reset to 2 poll options
                while (_pollControllers.length > 2) {
                  _pollControllers.removeLast().dispose();
                }
              });
              _animationController.reverse();
              HapticFeedback.mediumImpact();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildPrimaryButton(),
        ),
      ],
    );
  }

  Widget _buildSecondaryButton(String text, IconData icon, VoidCallback onTap) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _submitPost,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rocket_launch, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        _isPollMode ? 'Create Poll' : 'Share Post',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.5,
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

enum PostType { regular, poll }
