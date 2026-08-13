import 'package:bkkpet/blank_page/app_field_styles.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14, color: AppColors.greyscale_900),
      decoration: buildAppInputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.greyscale_400, size: 18),
      ).copyWith(suffixIcon: suffix),
    );
  }
}

/// ---------- Search Field (แยกจาก CustomTextField เพราะ layout ต่างกัน) ----------
class CustomSearchField extends StatelessWidget {
  const CustomSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.rightBtn = false,
    this.onFilterTap,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final bool rightBtn;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: buildAppInputDecoration(
        hintText: hintText,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            'assets/icons/icon_search.png',
            width: 24,
            color: AppColors.greyscale_800,
          ),
        ),
        radius: 18,
        borderColor: AppColors.greyscale_50,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
    );
  }
}
