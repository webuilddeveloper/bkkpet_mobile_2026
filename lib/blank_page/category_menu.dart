import 'package:flutter/material.dart';
import '../style_theme.dart';

class CategoryMenuWidget extends StatelessWidget {
  const CategoryMenuWidget({
    super.key,
    required this.items,
    required this.onCategoryTap,
  });

  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final visibleItemCount = items.length >= 5 ? 5 : items.length;
        final spacing = availableWidth < 360 ? 6.0 : 8.0;
        final itemWidth =
            ((availableWidth - (spacing * (visibleItemCount - 1))) /
                    visibleItemCount)
                .clamp(58.0, 82.0);
        final imageSize = (itemWidth * 0.74).clamp(44.0, 60.0);
        final fontSize = (itemWidth * 0.17).clamp(10.5, 13.0);
        final height = imageSize + 48;

        return SizedBox(
          height: height,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(width: spacing),
            itemBuilder: (context, index) {
              final item = items[index];

              return GestureDetector(
                onTap: () => onCategoryTap(item),
                child: SizedBox(
                  width: itemWidth,
                  child: Column(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          item['image'],
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['title'],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
