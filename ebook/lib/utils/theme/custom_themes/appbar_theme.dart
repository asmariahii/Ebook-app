import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class TAppBarTheme {
  TAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 1,
    centerTitle: true,
    scrolledUnderElevation: 1,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: TColors.darkGrey, size: 24),
    actionsIconTheme: IconThemeData(color: TColors.darkGrey, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: TColors.secondary,
    ),
  );

  static const darkAppBarTheme = AppBarTheme(
    elevation: 1,
    centerTitle: true,
    scrolledUnderElevation: 1,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: TColors.white, size: 24),
    actionsIconTheme: IconThemeData(color: TColors.white, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: TColors.white,
    ),
  );
}
