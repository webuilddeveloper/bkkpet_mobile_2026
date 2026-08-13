import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

InputDecoration buildAppInputDecoration({
  required String hintText,
  Widget? prefixIcon,
  Color fillColor = Colors.white,
  Color borderColor = AppColors.greyscale_200,
  Color focusedColor = AppColors.primary,
  double radius = 12,
  EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 14,
  ),
  bool isDense = true,
}) {
  return InputDecoration(
    isDense: isDense,
    hintText: hintText,
    hintStyle: TextStyle(fontSize: 13, color: AppColors.greyscale_300),
    prefixIcon: prefixIcon,
    filled: true,
    fillColor: fillColor,
    contentPadding: contentPadding,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: focusedColor, width: 1.5),
    ),
  );
}

Widget buildAppFieldLabel(String label, {bool required = false}) {
  return RichText(
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
  );
}

