import 'package:flutter/material.dart';

class SearchSection extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;

  const SearchSection({
    super.key,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Search the course',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: const Icon(Icons.tune),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onSubmitted: onSearch,
    );
  }
}
