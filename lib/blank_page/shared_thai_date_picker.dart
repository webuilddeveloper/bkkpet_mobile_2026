import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class SharedThaiDatePickerField extends StatelessWidget {
  const SharedThaiDatePickerField({
    super.key,
    required this.label,
    required this.date,
    required this.onPicked,
    this.firstDate,
    this.lastDate,
    this.required = false,
    this.hintText = 'เลือกวันที่',
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onPicked;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool required;
  final String hintText;

  String get _text {
    if (date == null) return '';
    final d = date!.day.toString().padLeft(2, '0');
    final m = date!.month.toString().padLeft(2, '0');
    return '$d/$m/${date!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 2),
            child: RichText(
              text: TextSpan(
                text: label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyscale_900,
                ),
                children:
                    required
                        ? const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ]
                        : null,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: date ?? (firstDate ?? now),
                firstDate: firstDate ?? DateTime(2000),
                lastDate: lastDate ?? now,
                locale: const Locale('th', 'TH'),
                helpText: 'เลือกวันที่',
                cancelText: 'ยกเลิก',
                confirmText: 'ตกลง',
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        onSurface: AppColors.greyscale_900,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) onPicked(picked);
            },
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.greyscale_200),
                color: Colors.white,
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.greyscale_400,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _text.isEmpty ? hintText : _text,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          _text.isEmpty
                              ? AppColors.greyscale_300
                              : AppColors.greyscale_900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
