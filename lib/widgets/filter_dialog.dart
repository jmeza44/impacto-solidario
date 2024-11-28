import 'package:flutter/material.dart';

class FilterDialog extends StatelessWidget {
  final String? selectedStatus;
  final Function(String?) onStatusChanged;
  final Function() onApplyFilters;

  const FilterDialog({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onApplyFilters,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Filters"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: selectedStatus,
            hint: const Text("Status"),
            items: ['Active', 'Completed', 'Cancelled']
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                .toList(),
            onChanged: onStatusChanged,
          ),
          // Add other filters here (e.g., date picker)
        ],
      ),
      actions: [
        TextButton(
          onPressed: onApplyFilters,
          child: const Text("Apply"),
        ),
      ],
    );
  }
}
