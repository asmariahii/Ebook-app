// Light & Dark Outlined Button Themes
import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class TOutlinedButtonTheme {
  TOutlinedButtonTheme._(); // To avoid creating instances

  // Light Theme
  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: TColors.primary,
      side: const BorderSide(color: TColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      textStyle: const TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
        color: TColors.textSecondary,
      ),
    ),
  );

  // Dark Theme
  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: TColors.white,
      side: const BorderSide(color: TColors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      textStyle: const TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
        color: TColors.textwhite,
      ),
    ),
  );
}
