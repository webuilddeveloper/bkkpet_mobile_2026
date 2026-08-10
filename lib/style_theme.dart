import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xff00744B);
  static const Color primarySecondary = Color(0xff2A4735);
  static const Color secondary = Color(0xffA4ACB9);
  static const Color primaryLight = Color.fromARGB(255, 202, 237, 100);
  static const Color greenlight = Color(0xffB7D666);
  static const Color greyscale_900 = Color(0xff0D0D12);
  static const Color greyscale_800 = Color(0xff39434F);
  static const Color greyscale_400 = Color(0xff818898);
  static const Color greyscale_300 = Color(0xffA4ACB9);
  static const Color greyscale_200 = Color(0xffD9DFE6);
  static const Color greyscale_50 = Color(0xffECEFF3);
  static const Color greyscale_25 = Color(0xffF6F8FA);
}

class StyleTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primary,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,

      surface: AppColors.greyscale_50,
      tertiary: AppColors.greyscale_900,
    ),

    scaffoldBackgroundColor: Colors.white,
  );
}
