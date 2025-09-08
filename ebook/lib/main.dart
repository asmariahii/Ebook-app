import 'package:ebook/utils/theme/custom_themes/test_showdialog.dart';
import 'package:flutter/material.dart';

import 'screens/home/route_pages.dart';
import 'screens/login/signin_page.dart';
import 'screens/login/signup_page.dart';
import 'screens/login/splash_page.dart';

import 'utils/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, 

      title: 'Flutter Demo',
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      home: RoutePages(),
    );
  }
}
