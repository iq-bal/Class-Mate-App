import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onSelected;

  const CategorySelector({
    Key? key,
    required this.categories,
    this.selectedCategory,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((category) {
        final isSelected = selectedCategory == category;
        return ChoiceChip(
          label: Text(
            category,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.teal.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
          selected: isSelected,
          selectedColor: Colors.teal,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.teal.shade200, width: 1),
          ),
          onSelected: (bool selected) => onSelected(selected ? category : null),
        );
      }).toList(),
    );
  }
}
