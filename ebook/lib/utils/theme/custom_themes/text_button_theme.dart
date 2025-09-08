import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class TTextButtonTheme {
  TTextButtonTheme._();

  // Light TextButton Theme
  static TextButtonThemeData lightTextButtonTheme = TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all<Color>(
        TColors.primary,
      ), // Text color for light theme
      backgroundColor: WidgetStateProperty.all<Color>(
        Colors.transparent,
      ), // Background color for light theme
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        TextStyle(fontSize: 21.0, fontWeight: FontWeight.w600),
      ),
    ),
  );

  // Dark TextButton Theme
  static TextButtonThemeData darkTextButtonTheme = TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all<Color>(
        TColors.grey,
      ), // Text color for dark theme
      backgroundColor: WidgetStateProperty.all<Color>(
        Colors.transparent,
      ), // Background color for dark theme
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        TextStyle(fontSize: 21.0, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
