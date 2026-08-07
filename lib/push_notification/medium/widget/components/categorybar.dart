import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/widgets/components/commonText.dart';

class CategoryTab extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryTab({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  // Icon theo từng category
  String get _label {
    return switch (category) {
      'general' => 'General',
      'technology' => 'Tech',
      'business' => 'Business',
      'sports' => 'Sports',
      'health' => 'Health',
      'science' => 'Science',
      'entertainment' => 'Entertainment',

      _ => category,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Commontext(
              title: _label,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              colorText: isSelected ? Colors.white : Colors.grey.shade800,
            ),
            // const SizedBox(width: 6),
            // Text(
            //   category[0].toUpperCase() + category.substring(1),
            //   style: TextStyle(
            //     fontSize: 13,
            //     fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            //     color: isSelected ? Colors.white : Colors.grey.shade600,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
