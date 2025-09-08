// Custom Class for Light & Dark Text Themes
import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class TCheckboxTheme {
  TCheckboxTheme._();

  // Customizable Light Text Theme
  static CheckboxThemeData lightCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors.primary;
      }
      return Colors.transparent;
    }),
  );

  // Customizable Dark Text Theme
  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),

    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors.primary;
      }
      return Colors.transparent;
    }),
  );
}
