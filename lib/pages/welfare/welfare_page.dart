import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/mock_data.dart';
import 'package:bkkpet/pages/welfare/welfare_detail_page.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class WelfarePage extends StatelessWidget {
  const WelfarePage({super.key, this.initialSelectedId});

  final String? initialSelectedId;

  @override
  Widget build(BuildContext context) {
    final items = welfareItems;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'สวัสดิการ',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _WelfareCard(
                item: item,
                highlight: item.id == initialSelectedId,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WelfareDetailPage(item: item),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WelfareItem {
  const WelfareItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.detail,
    required this.provider,
    required this.image,
    required this.benefit,
  });

  final String id;
  final String title;
  final String summary;
  final String detail;
  final String provider;
  final String image;
  final String benefit;

  factory WelfareItem.fromJson(Map<String, dynamic> json) {
    return WelfareItem(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      detail: json['detail'] as String,
      provider: json['provider'] as String,
      image: json['image'] as String,
      benefit: json['benefit'] as String,
    );
  }
}

final List<WelfareItem> welfareItems =
    mockWelfareItems.map(WelfareItem.fromJson).toList();

class _WelfareCard extends StatelessWidget {
  const _WelfareCard({
    required this.item,
    required this.highlight,
    required this.onTap,
  });

  final WelfareItem item;
  final bool highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              item.image,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.benefit,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primarySecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.greyscale_900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.summary,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.greyscale_400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  item.provider,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
