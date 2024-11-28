import 'package:flutter/material.dart';

class SearchAndFilters extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;

  const SearchAndFilters({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Row(
        children: [
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: selectedCategory,
            hint: const Text("Categoría"),
            items: ['Todas', 'Educación', 'Salud', 'Medio Ambiente'] // Example categories
                .map((category) => DropdownMenuItem(
              value: category == 'Todas' ? null : category,
              child: Text(category),
            ))
                .toList(),
            onChanged: onCategoryChanged,
          ),
        ],
      ),
    );
  }
}
