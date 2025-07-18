// lib/features/home/widgets/create_post_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/post/viewmodel/post_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePostDialog extends StatefulWidget {
  final WidgetRef ref;

  const CreatePostDialog({
    super.key,
    required this.ref,
  });

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppPallete.scaffoldBackgroundColorDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppPallete.gradient1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.create,
              color: AppPallete.whiteColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Create Wef',
            style: GoogleFonts.getFont(
              'Oswald',
              color: AppPallete.textPrimaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.getFont(
              'Oswald',
              color: AppPallete.textPrimaryDark,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _contentController.text.isNotEmpty) {
              widget.ref.read(postViewModelProvider.notifier).createPost(
                    title: _titleController.text,
                    content: _contentController.text,
                  );
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPallete.gradient2,
            foregroundColor: AppPallete.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Post',
            style: GoogleFonts.getFont(
              'Oswald',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}