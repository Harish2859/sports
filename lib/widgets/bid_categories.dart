import 'package:flutter/material.dart';

class BidCategories extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const BidCategories({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  static const List<String> categories = [
    'All',
    'Basketball',
    'Soccer',
    'Tennis',
    'Swimming',
    'Running',
    'Cycling',
    'Equipment',
    'Sponsorship',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(category),
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[700],
            ),
          );
        },
      ),
    );
  }
}