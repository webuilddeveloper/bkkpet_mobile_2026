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
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: AppColors.greyscale_400, fontSize: 13),
        hintStyle: TextStyle(color: AppColors.greyscale_300, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.greyscale_400, size: 20),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.greyscale_200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.greyscale_200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
      ),
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
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            'assets/icons/icon_search.png',
            width: 24,
            color: AppColors.greyscale_800,
          ),
        ),

        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.greyscale_800,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.greyscale_50),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.greyscale_50),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
    );
  }
}
