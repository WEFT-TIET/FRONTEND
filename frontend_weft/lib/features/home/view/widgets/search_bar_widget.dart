// lib/features/home/widgets/search_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearchFocused;
  final Function(String) onSearchChanged;
  final Function(bool) onFocusChanged;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.isSearchFocused,
    required this.onSearchChanged,
    required this.onFocusChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppPallete.whiteColor.withOpacity(isSearchFocused ? 0.3 : 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSearchFocused
              ? AppPallete.gradient1.withOpacity(0.6)
              : AppPallete.textPrimaryDark.withOpacity(0.3),
          width: isSearchFocused ? 2 : 1,
        ),
        boxShadow: isSearchFocused
            ? [
                BoxShadow(
                  color: AppPallete.gradient1.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: controller,
        onChanged: onSearchChanged,
        onTap: () => onFocusChanged(true),
        onEditingComplete: () => onFocusChanged(false),
        style: const TextStyle(color: AppPallete.textPrimaryDark),
        decoration: InputDecoration(
          hintText: 'Search posts by title...',
          hintStyle: TextStyle(
            color: AppPallete.textPrimaryDark.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppPallete.textPrimaryDark.withOpacity(0.6),
          ),
          suffixIcon: _buildSuffixIcon(),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (controller.text.isEmpty) return null;
    
    return IconButton(
      icon: const Icon(
        Icons.clear,
        color: AppPallete.textPrimaryDark,
      ),
      onPressed: onClear,
    );
  }
}