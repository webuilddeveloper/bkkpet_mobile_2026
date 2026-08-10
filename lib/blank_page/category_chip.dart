import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelected,
    required this.primaryColor,
  });

  final List<Map<String, dynamic>> items;
  final int selectedId;
  final ValueChanged<int> onSelected;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final bool isSelected = item['id'] == selectedId;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onSelected(item['id']),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.white : primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Text(
                  item['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : primaryColor,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
