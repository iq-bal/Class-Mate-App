import 'package:flutter/material.dart';

class SearchSection extends StatefulWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;

  const SearchSection({
    super.key,
    required this.searchController,
    required this.onSearch,
  });
  
  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  bool _showSuggestions = false;
  
  // Computer Science course suggestions
  final List<String> _csSuggestions = [
    'Data Structures and Algorithms',
    'Computer Networks',
    'Operating Systems',
    'Database Management Systems',
    'Artificial Intelligence',
    'Machine Learning',
    'Web Development',
    'Mobile App Development',
    'Computer Graphics',
    'Cybersecurity',
    'CSE101',
    'CSE201',
    'CSE301',
    'CSE401',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.searchController,
          decoration: InputDecoration(
            hintText: 'Search the course',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: GestureDetector(
              onTap: () {
                _showSuggestionsBottomSheet(context);
              },
              child: const Icon(Icons.tune),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onSubmitted: widget.onSearch,
        ),
      ],
    );
  }
  
  void _showSuggestionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Suggested Courses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _csSuggestions.map((suggestion) {
                  return GestureDetector(
                    onTap: () {
                      widget.searchController.text = suggestion;
                      widget.onSearch(suggestion);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        suggestion,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
