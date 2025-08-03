import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/post/viewmodel/post_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitPost() {
    if (_titleController.text.isNotEmpty &&
        _contentController.text.isNotEmpty) {
      ref
          .read(postViewModelProvider.notifier)
          .createPost(
            title: _titleController.text,
            content: _contentController.text,
          );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and content cannot be empty.'),
          backgroundColor: AppPallete.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.scaffoldBackgroundColorDark,
      appBar: AppBar(
        backgroundColor: AppPallete.scaffoldBackgroundColorDark,
        elevation: 0,
        title: Text(
          'Create Post',
          style: GoogleFonts.oswald(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppPallete.textPrimaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: Text(
              'Post',
              style: TextStyle(
                color: AppPallete.gradient2,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: AppPallete.textPrimaryDark),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(
                    color: AppPallete.textPrimaryDark.withOpacity(0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppPallete.glassWhite05,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  style: const TextStyle(color: AppPallete.textPrimaryDark),
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    hintText: 'What\'s on your mind?',
                    hintStyle: TextStyle(
                      color: AppPallete.textPrimaryDark.withOpacity(0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppPallete.glassWhite05,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
