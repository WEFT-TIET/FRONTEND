// lib/features/home/widgets/filter_chips_widget.dart
import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class FilterChipsWidget extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterChipsWidget({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) => onFilterChanged(filter),
              backgroundColor: AppPallete.whiteColor.withOpacity(0.2),
              selectedColor: AppPallete.gradient1.withOpacity(0.8),
               checkmarkColor: Colors.orange.withOpacity(0.8),
              labelStyle: TextStyle(
                color: isSelected
                    ? AppPallete.whiteColor
                    : AppPallete.textPrimaryDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : AppPallete.textPrimaryDark.withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    );
  }
}