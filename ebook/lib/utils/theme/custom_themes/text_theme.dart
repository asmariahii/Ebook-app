import 'package:ebook/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class TTextTheme {
  TTextTheme._();
  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
      fontSize: 35.0,
      fontWeight: FontWeight.bold,
      color: TColors.textSecondary,
    ),
    headlineMedium: const TextStyle().copyWith(
      fontSize: 27.0,
      fontWeight: FontWeight.w600,
      color: TColors.textSecondary,
    ),
    headlineSmall: const TextStyle().copyWith(
      fontSize: 21.0,
      fontWeight: FontWeight.w600,
      color: TColors.textSecondary,
    ),

    titleLarge: const TextStyle().copyWith(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: TColors.textSecondary,
    ),
    titleMedium: const TextStyle().copyWith(
      fontSize: 20.0,
      fontWeight: FontWeight.w500,
      color: TColors.textSecondary,
    ),
    titleSmall: const TextStyle().copyWith(
      fontSize: 20.0,
      fontWeight: FontWeight.w400,
      color: TColors.textSecondary,
    ),

    bodyLarge: const TextStyle().copyWith(
      fontSize: 19.0,
      fontWeight: FontWeight.w600,
      color: TColors.textSecondary,
    ),
    bodyMedium: const TextStyle().copyWith(
      fontSize: 19.0,
      fontWeight: FontWeight.w500,
      color: TColors.textSecondary,
    ),
    bodySmall: const TextStyle().copyWith(
      fontSize: 19.0,
      fontWeight: FontWeight.w400,
      color: TColors.textDarkGrey,
    ),

    labelLarge: const TextStyle().copyWith(
      fontSize: 15.0,
      fontWeight: FontWeight.w500,
      color: TColors.textgrey,
    ),
    labelMedium: const TextStyle().copyWith(
      fontSize: 13.0,
      fontWeight: FontWeight.w500,
      color: TColors.textgrey,
    ),
  );
  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
      fontSize: 35.0,
      fontWeight: FontWeight.bold,
      color: TColors.textwhite,
    ),
    headlineMedium: const TextStyle().copyWith(
      fontSize: 27.0,
      fontWeight: FontWeight.w600,
      color: TColors.textwhite,
    ),
    headlineSmall: const TextStyle().copyWith(
      fontSize: 21.0,
      fontWeight: FontWeight.w600,
      color: TColors.textwhite,
    ),

    titleLarge: const TextStyle().copyWith(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: TColors.textwhite,
    ),
    titleMedium: const TextStyle().copyWith(
      fontSize: 20.0,
      fontWeight: FontWeight.w500,
      color: TColors.textwhite,
    ),
    titleSmall: const TextStyle().copyWith(
      fontSize: 20.0,
      fontWeight: FontWeight.w400,
      color: TColors.textwhite,
    ),

    bodyLarge: const TextStyle().copyWith(
      fontSize: 19.0,
      fontWeight: FontWeight.w600,
      color: TColors.textwhite,
    ),
    bodyMedium: const TextStyle().copyWith(
      fontSize: 19.0,
      fontWeight: FontWeight.w500,
      color: TColors.textwhite,
    ),
    bodySmall: const TextStyle().copyWith(
      fontSize: 19.0,
      fontWeight: FontWeight.w400,
      color: TColors.textwhite,
    ),

    labelLarge: const TextStyle().copyWith(
      fontSize: 15.0,
      fontWeight: FontWeight.w500,
      color: TColors.textgrey,
    ),
    labelMedium: const TextStyle().copyWith(
      fontSize: 13.0,
      fontWeight: FontWeight.w500,
      color: TColors.textgrey,
    ),
  );
}
