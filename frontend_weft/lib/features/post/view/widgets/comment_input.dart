import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class CommentInput extends ConsumerStatefulWidget {
  final Function(String) onSubmit;
  final bool isLoading;

  const CommentInput({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  ConsumerState<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<CommentInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitComment() {
    final content = _controller.text.trim();
    if (content.isNotEmpty && !widget.isLoading) {
      widget.onSubmit(content);
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPallete.glassWhite05,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPallete.glassWhite20, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(
                color: AppPallete.textPrimaryDark,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(
                  color: AppPallete.whiteColor,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.isLoading ? null : _submitComment,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.isLoading 
                    ? AppPallete.glassWhite20 
                    : AppPallete.gradient2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppPallete.whiteColor),
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: AppPallete.whiteColor,
                      size: 18,
                    ),
            ),
          ),
        ],
      ),
    );
  }
} 