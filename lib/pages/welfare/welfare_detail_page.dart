import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/pages/welfare/welfare_page.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class WelfareDetailPage extends StatelessWidget {
  const WelfareDetailPage({super.key, required this.item});

  final WelfareItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'รายละเอียดสวัสดิการ',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.greyscale_200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.asset(
                    item.image,
                    height: 210,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.benefit,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primarySecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.greyscale_900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.summary,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: AppColors.greyscale_400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _InfoBlock(label: 'ผู้ให้บริการ', value: item.provider),
                      const SizedBox(height: 12),
                      _InfoBlock(label: 'รายละเอียด', value: item.detail),
                    ],
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

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.greyscale_50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.greyscale_800,
            ),
          ),
        ],
      ),
    );
  }
}
